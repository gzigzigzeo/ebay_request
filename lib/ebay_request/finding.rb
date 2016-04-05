class EbayRequest::Finding < EbayRequest::Base
  include EbayRequest::Xml

  def initialize(options = {})
    super
    options[:globalid] ||= "EBAY-US"
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
      "X-EBAY-SOA-SECURITY-APPNAME" => EbayRequest.config.appid,
      "X-EBAY-SOA-OPERATION-NAME" => callname,
      "X-EBAY-SOA-REQUEST-DATA-FORMAT" => "XML",
      "X-EBAY-SOA-GLOBAL-ID" => options[:globalid].to_s
    )
  end

  def error_message_for(r)
    r["errorMessage"]["error"]["message"]
  end
end
