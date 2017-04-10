# frozen_string_literal: true

require "spec_helper"

describe EbayRequest::BusinessPolicies do
  subject { described_class.new(siteid: "SITEID", token: "some_token") }

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

  let(:response_with_errors) do
    %(<?xml version='1.0' encoding='UTF-8'?><getSellerProfilesResponse \
xmlns="http://www.ebay.com/marketplace/selling/v1/services">\
<ack>Failure</ack><errorMessage><error><severity>Error</severity>\
<message>Some error</message><errorId>123</errorId></error>\
<error><severity>Warning</severity>\
<message>Some warning</message><errorId>11</errorId></error>
</errorMessage></getSellerProfilesResponse>)
  end

  it "sends request and parses response" do
    stub_request(
      :post, "https://svcs.sandbox.ebay.com/services/selling/v1/#{service_name}"
    )
      .with(
        body: request,
        headers: headers
      )
      .to_return(status: 200, body: successful_response)

    expect(subject.response("getSellerProfiles", {})).to be_success
  end

  it "sends request and parses response with errors" do
    stub_request(
      :post, "https://svcs.sandbox.ebay.com/services/selling/v1/#{service_name}"
    )
      .with(
        body: request,
        headers: headers
      )
      .to_return(status: 200, body: response_with_errors)

    response = subject.response("getSellerProfiles", {})

    expect(response).not_to be_success
    expect(response.errors).to eq(123 => "Some error")
    expect(response.warnings).to eq(11 => "Some warning")
  end
end
