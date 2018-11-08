# frozen_string_literal: true

class EbayRequest::Trading < EbayRequest::Base
  class IllegalItemStateError < EbayRequest::Error; end
  class ItemLimitReachedError < EbayRequest::Error; end
  class DailyItemCallLimitReachedError < EbayRequest::Error; end
  class TokenValidationFailed < EbayRequest::Error; end
  class IAFTokenExpired < TokenValidationFailed; end
  class AccountSuspended < EbayRequest::Error; end
  class AccountClosed < EbayRequest::Error; end
  class ApplicationInvalid < EbayRequest::Error; end

  private

  def payload(callname, request)
    key_converter = :camelcase
    request = Gyoku.xml(request, key_converter: key_converter)

    %(<?xml version="1.0" encoding="utf-8"?>\
<#{callname}Request xmlns="urn:ebay:apis:eBLBaseComponents">\
#{creds}#{request}</#{callname}Request>)
  end

  def creds
    return if options[:token].nil? || options[:iaf_token_manager]
    %(<RequesterCredentials>\
<eBayAuthToken>#{options[:token]}</eBayAuthToken>\
</RequesterCredentials>)
  end

  def endpoint
    "https://api%{sandbox}.ebay.com/ws/api.dll"
  end

  def headers(callname)
    super.merge default_headers(callname).merge(auth_header)
  end

  def default_headers(callname)
    {
      "Content-Type" => "text/xml",
      "X-EBAY-API-APP-NAME" => config.appid,
      "X-EBAY-API-DEV-NAME" => config.devid,
      "X-EBAY-API-CERT-NAME" => config.certid,
      "X-EBAY-API-COMPATIBILITY-LEVEL" => config.version.to_s,
      "X-EBAY-API-CALL-NAME" => callname,
      "X-EBAY-API-SITEID" => siteid.to_s,
    }
  end

  def auth_header
    return {} unless options[:iaf_token_manager]
    { "X-EBAY-API-IAF-TOKEN" => options[:iaf_token_manager].access_token }
  end

  def errors_for(response)
    [response["Errors"]]
      .flatten
      .compact
      .map { |err| [err["SeverityCode"], err["ErrorCode"], err["LongMessage"]] }
  end

  def request(*)
    retried ||= false
    super.tap do |response|
      next if retried || options[:iaf_token_manager].nil?
      next if response.success? || response.error_class > IAFTokenExpired
      raise response.error
    end
  rescue IAFTokenExpired
    options[:iaf_token_manager].refresh!
    retried = true
    retry
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
    21_916_984 => TokenValidationFailed,
    21_917_053 => IAFTokenExpired,
    32         => AccountSuspended,
    212        => AccountSuspended,
    841        => AccountSuspended,
    20_960     => AccountSuspended,
    21_532     => AccountSuspended,
    21_548     => AccountSuspended,
    21_915_268 => AccountSuspended,
    31         => AccountClosed,
    11_106     => AccountClosed,
    21_930     => AccountClosed,
    127        => ApplicationInvalid,
  }.freeze
end
