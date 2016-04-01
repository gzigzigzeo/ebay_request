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

  context "#response" do
    let(:failing_request) do
      "{\"jsonns.xsi\":\"http://www.w3.org/2001/XMLSchema-instance\",\
\"jsonns.xs\":\"http://www.w3.org/2001/XMLSchema\",\"jsonns.tns\"\
:\"http://www.ebay.com/marketplace/search/v1/services\",\
\"tns.findItemsByKeywordsRequest\":{}}"
    end

    let(:failing_response) do
      "{\"findItemsByKeywordsResponse\":[{\"ack\":[\"Failure\"],\
\"errorMessage\":[{\"error\":[{\"errorId\":[\"2\"],\"domain\":\
[\"Marketplace\"],\"severity\":[\"Error\"],\"category\":[\"Request\"],\
\"message\":[\"Keywords value required.\"],\"subdomain\":[\"Search\"]}]}]\
,\"version\":[\"1.13.0\"],\"timestamp\":[\"2016-04-01T16:22:50.643Z\"]}]}"
    end

    it "with errors" do
      stub_request(
        :post, "http://svcs.sandbox.ebay.com/services/search/FindingService/v1"
      )
        .with(
          body: failing_request,
          headers: {
            "X-Ebay-Soa-Global-Id" => "EBAY-US",
            "X-Ebay-Soa-Operation-Name" => "findItemsByKeywords",
            "X-Ebay-Soa-Request-Data-Format" => "JSON",
            "X-Ebay-Soa-Security-Appname" => "1",
            "X-Ebay-Soa-Service-Name" => "FindingService",
            "X-Ebay-Soa-Service-Version" => "1.0.0"
          }
        )
        .to_return(status: 200, body: failing_response)

      expect { subject.response("findItemsByKeywords", {}) }.to raise_error(
        EbayRequest::Error, /Keywords value required/
      )
    end

    it "success" do
      expect(subject.response("findItemsByKeywords", keywords: "iPad")).to(
      
      )
    end
  end
end
