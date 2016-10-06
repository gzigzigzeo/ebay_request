class EbayRequest::Trading < EbayRequest::Base
  include EbayRequest::Xml
  include EbayRequest::SiteId

  class IllegalItemStateError < EbayRequest::Error; end
  class ItemLimitReachedError < EbayRequest::Error; end
  class DailyItemCallLimitReachedError < EbayRequest::Error; end
  class TokenValidationFailed < EbayRequest::Error; end
  class AccountSuspended < EbayRequest::Error; end
  class ApplicationInvalid < EbayRequest::Error; end

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

  def errors_for(r)
    [r["Errors"]]
      .flatten
      .compact
      .map { |e| [e["SeverityCode"], e["ErrorCode"], e["LongMessage"]] }
  end

  def specific_error_classes
    {
      IllegalItemStateError => [291, 1047], # Revise or close closed listing
      ItemLimitReachedError => [21_919_188],
      DailyItemCallLimitReachedError => [21_919_165],
      TokenValidationFailed => [931, 17_470, 16_110],
      AccountSuspended => [841],
      ApplicationInvalid => [127]
    }
  end
end
