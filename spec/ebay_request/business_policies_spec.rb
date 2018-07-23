# frozen_string_literal: true

require "spec_helper"

describe EbayRequest::BusinessPolicies do
  subject { described_class.new(siteid: "0", token: "some_token") }

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
      "Content-Type"              => "text/xml",
      "X-EBAY-SOA-SECURITY-TOKEN" => "some_token",
      "X-EBAY-SOA-SERVICE-NAME"   => "SellerProfilesManagementService",
      "X-EBAY-SOA-OPERATION-NAME" => "getSellerProfiles",
      "X-EBAY-SOA-CONTENT-TYPE"   => "XML",
      "X-EBAY-SOA-GLOBAL-ID"      => "EBAY-US",
    }
  end

  let(:request) do
    %(<?xml version="1.0" encoding="utf-8"?>\
<getSellerProfilesRequest xmlns="http://www.ebay.com/marketplace/selling">\
</getSellerProfilesRequest>)
  end

  let(:failing_request) do
    %(<?xml version="1.0" encoding="utf-8"?><getSellerProfilesRequest \
xmlns="http://www.ebay.com/marketplace/selling">\
<item><title>i</title></item></getSellerProfilesRequest>)
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

  let(:response_with_expired_iaf_token_error) do
    %(<?xml version='1.0' encoding='UTF-8'?><getSellerProfilesResponse \
xmlns="http://www.ebay.com/marketplace/selling/v1/services">\
<ack>Failure</ack><errorMessage><error><category>Request</category>\
<domain>EBAY-US</domain><errorId>21917053</errorId><exceptionId>1</exceptionId>\
<message>Error</message><severity>Error</severity>\
<subdomain>EBAY-US</subdomain></error></errorMessage>\
</getSellerProfilesResponse>)
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

  context("using IAF token") do
    subject { described_class.new(iaf_token_manager: token_manager) }

    let(:token_manager) do
      double("IAF token manager", refresh!: nil, access_token: "some_token")
    end

    let(:headers) do
      {
        "Content-Type"                 => "text/xml",
        "X-EBAY-SOA-SECURITY-IAFTOKEN" => "some_token",
        "X-EBAY-SOA-SERVICE-NAME"      => "SellerProfilesManagementService",
        "X-EBAY-SOA-OPERATION-NAME"    => "getSellerProfiles",
        "X-EBAY-SOA-CONTENT-TYPE"      => "XML",
        "X-EBAY-SOA-GLOBAL-ID"         => "EBAY-US",
      }
    end

    let(:service) do
      "https://svcs.sandbox.ebay.com/services/selling/v1/"\
      "SellerProfilesManagementService"
    end

    let!(:api) do
      stub_request(:post, service)
        .with(body: failing_request, headers: headers)
        .to_return(status: 200, body: response_with_expired_iaf_token_error)
        .to_return(status: 200, body: successful_response)
    end

    it "#response with iaf token expired error tries to refresh token" do
      response = subject.response("getSellerProfiles", Item: { Title: "i" })

      expect(token_manager).to have_received(:refresh!)
      expect(response).to be_success
      expect(response.errors).to eq({})
      expect(response.warnings).to eq({})
      expect(response.data!).to be
      expect(api).to have_been_requested.twice
    end
  end
end
