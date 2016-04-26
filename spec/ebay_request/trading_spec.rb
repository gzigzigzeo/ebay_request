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

  let(:warning_response_single_error) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Warning</Ack><Errors>
<LongMessage>This listing may be identical to test item</LongMessage>
</Errors></AddItemResponse>)
  end

  let(:failure_response_multiple_errors) do
    %(<AddItemResponse xmlns="urn:ebay:apis:eBLBaseComponents">
<Timestamp>2016-04-18T12:12:26.600Z</Timestamp><Ack>Failure</Ack><Errors>
<LongMessage>Error 1</LongMessage>
</Errors><Errors>
<LongMessage>This listing may be identical to test item</LongMessage>
</Errors></AddItemResponse>)
  end

  it "#response with single error" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: warning_response_single_error)

    expect { subject.response("AddItem", Item: { Title: "i" }) }.to raise_error(
      EbayRequest::Error, "This listing may be identical to test item"
    )
  end

  it "#response with multiple errors" do
    stub_request(
      :post, "https://api.sandbox.ebay.com/ws/api.dll"
    )
      .with(
        body: failing_request,
        headers: headers
      )
      .to_return(status: 200, body: failure_response_multiple_errors)

    expect { subject.response("AddItem", Item: { Title: "i" }) }.to raise_error(
      EbayRequest::Error, /Error 1, This listing may be identical to test item/
    )
  end

  context "when ignoring warnings" do
    subject { described_class.new(ignore_warnings: true) }

    it "#response with warning response" do
      stub_request(
        :post, "https://api.sandbox.ebay.com/ws/api.dll"
      )
        .with(
          body: failing_request,
          headers: headers
        )
        .to_return(status: 200, body: warning_response_single_error)

      expect(subject.response("AddItem", Item: { Title: "i" })).to be
    end
  end
end
