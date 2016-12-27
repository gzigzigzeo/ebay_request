class EbayRequest::Finding < EbayRequest::Base
  def globalid
    options[:globalid] || "EBAY-US"
  end

  private

  def payload(callname, request)
    request = Gyoku.xml(request)

    %(<?xml version="1.0" encoding="utf-8"?><#{callname}Request\
 xmlns="http://www.ebay.com/marketplace/search/v1/services">\
#{request}</#{callname}Request>)
  end

  def endpoint
    "http://svcs%{sandbox}.ebay.com/services/search/FindingService/v1"
  end

  def headers(callname)
    super.merge(
      "X-EBAY-SOA-SERVICE-NAME" => "FindingService",
      "X-EBAY-SOA-SERVICE-VERSION" => "1.0.0",
      "X-EBAY-SOA-SECURITY-APPNAME" => config.appid,
      "X-EBAY-SOA-OPERATION-NAME" => callname,
      "X-EBAY-SOA-REQUEST-DATA-FORMAT" => "XML",
      "X-EBAY-SOA-GLOBAL-ID" => globalid.to_s
    )
  end

  def errors_for(r)
    [r.dig("errorMessage", "error")]
      .flatten
      .compact
      .map { |e| [e["severity"], e["errorId"], e["message"]] }
  end

  FATAL_ERRORS = {}.freeze
end
