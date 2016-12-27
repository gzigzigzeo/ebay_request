class EbayRequest::Trading < EbayRequest::Base
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
#{creds}#{request}</#{callname}Request>)
  end

  def creds
    return if options[:token].nil?
    %(<RequesterCredentials>\
<eBayAuthToken>#{options[:token]}</eBayAuthToken>\
</RequesterCredentials>)
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
      "X-EBAY-API-SITEID" => siteid.to_s
    )
  end

  def errors_for(r)
    [r["Errors"]]
      .flatten
      .compact
      .map { |e| [e["SeverityCode"], e["ErrorCode"], e["LongMessage"]] }
  end

  # http://developer.ebay.com/devzone/xml/docs/reference/ebay/errors/errormessages.htm
  FATAL_ERRORS = {
    291        => IllegalItemStateError,
    1047       => IllegalItemStateError,
    21_919_188 => ItemLimitReachedError,
    21_919_165 => DailyItemCallLimitReachedError,
    931        => TokenValidationFailed,
    17_470     => TokenValidationFailed,
    16_110     => TokenValidationFailed,
    841        => AccountSuspended,
    127        => ApplicationInvalid
  }.freeze
end
