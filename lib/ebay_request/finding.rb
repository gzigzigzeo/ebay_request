class EbayRequest::Finding < EbayRequest::Base
  def initialize(options = {})
    super

    options[:globalid] ||= "EBAY-US"
  end

  private

  def payload(callname, request)
    {
      "jsonns.xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "jsonns.xs" => "http://www.w3.org/2001/XMLSchema",
      "jsonns.tns" => "http://www.ebay.com/marketplace/search/v1/services",
      "tns.#{callname}Request" => request
    }
  end

  def endpoint
    "http://svcs%{sandbox}.ebay.com/services/search/FindingService/v1"
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

  def parse(response)
    JSON.parse(response)
  end

  def process(response, callname)
    response["#{callname}Response"].tap do |r|
      raise EbayRequest::Error if r.nil?

      if r.first["ack"] != "Success"
        raise(
          EbayRequest::Error,
          r.first["errorMessage"].first["error"].first["message"].first
        )
      end
    end
  end
end
