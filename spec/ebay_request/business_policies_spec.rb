require "spec_helper"

describe EbayRequest::BusinessPolicies do
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

  let(:service_name) { "SellerProfilesManagementService" }

  let(:headers) do
    {
      "Content-Type" => "text/xml",
      "X-EBAY-SOA-SECURITY-TOKEN" => "some_token",
      "X-EBAY-SOA-SERVICE-NAME" => service_name,
      "X-EBAY-SOA-OPERATION-NAME" => "getSellerProfiles",
      "X-EBAY-SOA-CONTENT-TYPE" => "XML",
      "X-EBAY-SOA-GLOBAL-ID" => "SITEID"
    }
  end

  let(:request) do
    %(<?xml version="1.0" encoding="utf-8"?>\
<getSellerProfilesRequest xmlns="http://www.ebay.com/marketplace/selling">\
</getSellerProfilesRequest>)
  end

  let(:successful_response) do
    %(<?xml version='1.0' encoding='UTF-8'?><getSellerProfilesResponse \
xmlns="http://www.ebay.com/marketplace/selling/v1/services">\
<ack>Success</ack></getSellerProfilesResponse>)
  end

  subject { described_class.new(siteid: "SITEID", token: "some_token") }

  it "sends request and parses response" do
    stub_request(
      :post, "https://svcs.sandbox.ebay.com/services/selling/v1/#{service_name}"
    )
      .with(
        body: request,
        headers: headers
      )
      .to_return(status: 200, body: successful_response)

    expect(subject.response("getSellerProfiles", {})).to be
  end
end
