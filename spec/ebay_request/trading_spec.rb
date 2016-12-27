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
      "X-Ebay-Api-Siteid" => "0"
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
    expect(response.errors).to eq({})
    expect(response.warnings).to eq({})

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
    expect(response.errors).to eq(
      123 => "This listing may be identical to test item"
    )
    expect(response.warnings).to eq({})

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

    response = subject.response("AddItem", Item: { Title: "i" })

    expect(response).to be_success
    expect(response.errors).to eq({})
    expect(response.warnings).to eq(42 => "Some warning")
    expect(EbayRequest).to receive(:log_warn).and_return(true)

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
    expect(response.errors).to eq(
      11  => "Error 1",
      123 => "This listing may be identical to test item"
    )
    expect(response.warnings).to eq(57 => "Some other warning")

    expect(EbayRequest).to_not receive(:log_warn)

    expect { response.data! }.to raise_error(
      EbayRequest::Error,
      "Error 1, This listing may be identical to test item"
    )
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
    expect(response.errors).to eq(
      291 => "This listing may be identical to test item"
    )
    expect(EbayRequest).to_not receive(:log_warn)
    expect { response.data! }.to raise_error(
      EbayRequest::Trading::IllegalItemStateError,
      "This listing may be identical to test item"
    )
  end
end
