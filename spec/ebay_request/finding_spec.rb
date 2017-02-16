require "spec_helper"

describe EbayRequest::Finding do
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

  let(:failing_request) do
    "<?xml version=\"1.0\" encoding=\"utf-8\"?><findItemsByKeywordsRequest\
 xmlns=\"http://www.ebay.com/marketplace/search/v1/services\">\
</findItemsByKeywordsRequest>"
  end

  let(:failing_response) do
    %(<?xml version='1.0' encoding='UTF-8'?><findItemsByKeywordsResponse \
xmlns="http://www.ebay.com/marketplace/search/v1/services">\
<ack>Failure</ack><errorMessage><error><errorId>2</errorId>
<domain>Marketplace</domain><severity>Error</severity>
<category>Request</category><message>Keywords value required.</message>
<subdomain>Search</subdomain></error></errorMessage><version>1.13.0</version>
<timestamp>2016-04-01T17:39:51.046Z</timestamp></findItemsByKeywordsResponse>)
  end

  it "#response" do
    stub_request(
      :post, "http://svcs.sandbox.ebay.com/services/search/FindingService/v1"
    ).with(
      body: failing_request,
      headers: {
        "X-Ebay-Soa-Global-Id" => "EBAY-US",
        "X-Ebay-Soa-Operation-Name" => "findItemsByKeywords",
        "X-Ebay-Soa-Request-Data-Format" => "XML",
        "X-Ebay-Soa-Security-Appname" => "1",
        "X-Ebay-Soa-Service-Name" => "FindingService",
        "X-Ebay-Soa-Service-Version" => "1.9.0"
      }
    )
      .to_return(status: 200, body: failing_response)

    response = subject.response("findItemsByKeywords", {})

    expect(response).not_to be_success
    expect(response.errors).to eq(2 => "Keywords value required.")

    expect { response.data! }.to raise_error(
      EbayRequest::Error, /Keywords value required/
    )
  end
end
