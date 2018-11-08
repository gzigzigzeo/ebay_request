# frozen_string_literal: true

require "spec_helper"

describe EbayRequest::Trading do
  let(:config) do
    EbayRequest::Config.new.tap do |c|
      c.appid = "1"
      c.certid = "2"
      c.devid = "3"
      c.runame = "4"
    end
  end

  before do
    allow(EbayRequest).to receive(:config).and_return(config)
  end

  let(:headers) do
    {
      "X-Ebay-Api-App-Name" => "1",
      "X-Ebay-Api-Call-Name" => "AddItem",
      "X-Ebay-Api-Cert-Name" => "2",
      "X-Ebay-Api-Compatibility-Level" => "941",
      "X-Ebay-Api-Dev-Name" => "3",
      "X-Ebay-Api-Siteid" => "0",
    }
  end

  let(:failing_request) do
    %(<?xml version="1.0" encoding="utf-8"?><AddItemRequest \
xmlns="urn:ebay:apis:eBLBaseComponents">\
<Item><Title>i</Title></Item></AddItemRequest>)
  end

  let(:successful_response) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Success</Ack>
</AddItemResponse>)
  end

  let(:response_with_error) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Failure</Ack><Errors>
<SeverityCode>Error</SeverityCode><ErrorCode>123</ErrorCode>
<LongMessage>This listing may be identical to test item</LongMessage>
</Errors></AddItemResponse>)
  end

  let(:response_with_specific_error) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Failure</Ack><Errors>
<SeverityCode>Error</SeverityCode><ErrorCode>291</ErrorCode>
<LongMessage>This listing may be identical to test item</LongMessage>
</Errors></AddItemResponse>)
  end

  let(:response_with_expired_iaf_token_error) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2017-10-10T11:07:21.220Z</Timestamp><Ack>Failure</Ack><Errors>
<ShortMessage>Expired IAF token.</ShortMessage>
<LongMessage>IAF token supplied is expired. </LongMessage>
<SeverityCode>Error</SeverityCode><ErrorCode>21917053</ErrorCode>
</Errors></AddItemResponse>)
  end

  let(:response_with_warning) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Warning</Ack><Errors>
<SeverityCode>Warning</SeverityCode><ErrorCode>42</ErrorCode>
<LongMessage>Some warning</LongMessage>
</Errors></AddItemResponse>)
  end

  let(:response_with_multiple_errors) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Failure</Ack><Errors>
<SeverityCode>Error</SeverityCode><ErrorCode>11</ErrorCode>
<LongMessage>Error 1</LongMessage></Errors><Errors>
<SeverityCode>Error</SeverityCode><ErrorCode>123</ErrorCode>
<LongMessage>This listing may be identical to test item</LongMessage>
</Errors><Errors>
<SeverityCode>Warning</SeverityCode><ErrorCode>57</ErrorCode>
<LongMessage>Some other warning</LongMessage>
</Errors></AddItemResponse>)
  end
  let(:response_with_multiple_errors_and_params) do
    File.read("spec/fixtures/response_with_multiple_parameterized_errors.xml")
  end

  it "#response with no errors or warnings" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: successful_response)

    response = subject.response("AddItem", Item: { Title: "i" })

    expect(response).to be_success
    expect(response.errors).to be_empty
    expect(response.warnings).to be_empty

    expect(response.data!).to be
  end

  it "#response with single error" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: response_with_error)

    response = subject.response("AddItem", Item: { Title: "i" })

    expect(response).not_to be_success
    expect(response.errors).to contain_error(
      code: 123, message: "This listing may be identical to test item"
    )
    expect(response.warnings).to be_empty

    expect { response.data! }.to raise_error(
      EbayRequest::Error,
      "This listing may be identical to test item"
    )
  end

  it "#response with single warning" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: response_with_warning)

    expect(EbayRequest).to receive(:log_warn).and_return(true)

    response = subject.response("AddItem", Item: { Title: "i" })

    expect(response).to be_success
    expect(response.errors).to be_empty
    expect(response.warnings).to \
      contain_warning(code: 42, message: "Some warning")
    expect(response.data!).to be
  end

  it "#response with multiple errors" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: response_with_multiple_errors)

    response = subject.response("AddItem", Item: { Title: "i" })

    expect(response).not_to be_success
    expect(response.errors).to contain_error(code: 11, message: "Error 1")
    expect(response.errors).to contain_error(
      code: 123, message: "This listing may be identical to test item"
    )
    expect(response.warnings).to \
      contain_warning(code: 57, message: "Some other warning")

    expect(EbayRequest).to_not receive(:log_warn)

    expect { response.data! }.to raise_error(
      EbayRequest::Error,
      "Error 1, This listing may be identical to test item"
    )
  end

  it "#response with multiple parameterized errors" do
    stub_request(:post, "https://api.sandbox.ebay.com/ws/api.dll")
      .with(body: failing_request, headers: headers)
      .to_return(status: 200, body: response_with_multiple_errors_and_params)

    response = subject.response("AddItem", Item: { Title: "i" })

    expect { response.data! }.to raise_error(EbayRequest::Error) do |ex|
      expect(ex.errors.size).to eq(2)
      expect(ex.errors).to \
        contain_error(code: 21916260, params: eq("0" => "3.50"))
      expect(ex.errors).to \
        contain_error(code: 21919309, params: include("2" => "Gender"))
    end
  end

  it "#response with specific error" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: response_with_specific_error)

    response = subject.response("AddItem", Item: { Title: "i" })

    expect(response).not_to be_success
    expect(response.errors).to contain_error(
      code: 291, message: "This listing may be identical to test item"
    )
    expect(EbayRequest).to_not receive(:log_warn)
    expect { response.data! }.to raise_error(
      EbayRequest::Trading::IllegalItemStateError,
      "This listing may be identical to test item"
    )
  end

  context("using IAF token") do
    subject { described_class.new(iaf_token_manager: token_manager) }

    let(:token_manager) do
      double("IAF token manager", refresh!: nil, access_token: "some_token")
    end

    let!(:api) do
      stub_request(:post, "https://api.sandbox.ebay.com/ws/api.dll")
        .with(body: failing_request, headers: headers)
        .to_return(status: 200, body: response_with_expired_iaf_token_error)
        .to_return(status: 200, body: successful_response)
    end

    it "#response with iaf token expired error tries to refresh token" do
      response = subject.response("AddItem", Item: { Title: "i" })

      expect(token_manager).to have_received(:refresh!)
      expect(response).to be_success
      expect(response.errors).to be_empty
      expect(response.warnings).to be_empty
      expect(response.data!).to be
      expect(api).to have_been_requested.twice
    end
  end
end
