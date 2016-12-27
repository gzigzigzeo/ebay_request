class EbayRequest::Shopping < EbayRequest::Base
  include EbayRequest::SiteId

  private

  def payload(callname, request)
    request = Gyoku.xml(request)

    %(<?xml version="1.0" encoding="utf-8"?>\
<#{callname}Request xmlns="urn:ebay:apis:eBLBaseComponents">\
#{request}</#{callname}Request>)
  end

  def endpoint
    "http://open.api%{sandbox}.ebay.com/shopping"
  end

  def headers(callname)
    super.merge(
      "Content-Type" => "text/xml",
      "X-EBAY-API-APP-ID" => config.appid,
      "X-EBAY-API-VERSION" => config.version.to_s,
      "X-EBAY-API-CALL-NAME" => callname,
      "X-EBAY-API-REQUEST-ENCODING" => "XML",
      "X-EBAY-API-SITE-ID" => options[:siteid].to_s
    )
  end

  def errors_for(r)
    [r["Errors"]]
      .flatten
      .compact
      .map { |e| [e["SeverityCode"], e["ErrorCode"], e["LongMessage"]] }
  end
end
