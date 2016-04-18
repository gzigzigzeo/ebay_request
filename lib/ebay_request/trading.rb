class EbayRequest::Trading < EbayRequest::Base
  include EbayRequest::Xml
  include EbayRequest::SiteId

  private

  def payload(callname, request)
    request = Gyoku.xml(request, key_converter: :camelcase)

    %(<?xml version="1.0" encoding="utf-8"?>\
<#{callname}Request xmlns="urn:ebay:apis:eBLBaseComponents">\
#{request}</#{callname}Request>)
  end

  def endpoint
    "https://api%{sandbox}.ebay.com/ws/api.dll"
  end

  def headers(callname)
    super.merge(
      "Content-Type" => "text/xml",
      "X-EBAY-API-APP-NAME" => EbayRequest.config.appid,
      "X-EBAY-API-DEV-NAME" => EbayRequest.config.devid,
      "X-EBAY-API-CERT-NAME" => EbayRequest.config.certid,
      "X-EBAY-API-COMPATIBILITY-LEVEL" => EbayRequest.config.version.to_s,
      "X-EBAY-API-CALL-NAME" => callname,
      "X-EBAY-API-SITEID" => options[:siteid].to_s
    )
  end

  def error_message_for(r)
    [[r["Errors"]]]
      .flatten
      .map { |e| e["LongMessage"] }
      .join(", ")
  end
end
