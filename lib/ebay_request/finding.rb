class EbayRequest::Finding < EbayRequest::Base
  def initialize(_)
    super

    options[:globalid] ||= "EBAY-US"
  end

  private

  def endpoint
    "http://svcs%{sandbox}.ebay.com/services/search/FindingService/v1"
  end

  def ns
    "http://www.ebay.com/marketplace/search/v1/services"
  end

  def headers(callname)
    super.merge(
      "X-EBAY-SOA-SERVICE-NAME" => "FindingService",
      "X-EBAY-SOA-SERVICE-VERSION" => "1.0.0",
      "X-EBAY-SOA-SECURITY-APPNAME" => EbayRequest.config.appid,
      "X-EBAY-SOA-OPERATION-NAME" => callname,
      "X-EBAY-SOA-REQUEST-DATA-FORMAT" => "JSON",
      "X-EBAY-SOA-GLOBAL-ID" => options[:globalid].to_s
    )
  end
end
