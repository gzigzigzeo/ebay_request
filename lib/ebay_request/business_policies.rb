# frozen_string_literal: true

class EbayRequest::BusinessPolicies < EbayRequest::Base
  IAFTokenExpired = Class.new(EbayRequest::Error)

  private

  SERVICE_NAME = "SellerProfilesManagementService"

  def payload(callname, request)
    key_converter = ->(key) { EbayRequest::Inflector.camelcase_lower(key) }
    request       = Gyoku.xml(request, key_converter: key_converter)

    %(<?xml version="1.0" encoding="utf-8"?>\
<#{callname}Request xmlns="http://www.ebay.com/marketplace/selling">\
#{request}</#{callname}Request>)
  end

  def endpoint
    "https://svcs%{sandbox}.ebay.com/services/selling/v1/#{SERVICE_NAME}"
  end

  def headers(callname)
    super.merge default_headers(callname).merge(auth_header)
  end

  def global_id(siteid)
    EbayRequest::Config.globalid_from_site_id(siteid)
  end

  def default_headers(callname)
    {
      "Content-Type"              => "text/xml",
      "X-EBAY-SOA-CONTENT-TYPE"   => "XML",
      "X-EBAY-SOA-GLOBAL-ID"      => global_id(siteid.to_i),
      "X-EBAY-SOA-SERVICE-NAME"   => SERVICE_NAME,
      "X-EBAY-SOA-OPERATION-NAME" => callname,
    }
  end

  def auth_header
    if options[:iaf_token_manager]
      token = options[:iaf_token_manager].access_token
      { "X-EBAY-SOA-SECURITY-IAFTOKEN" => token }
    else
      token = options[:token]
      { "X-EBAY-SOA-SECURITY-TOKEN" => token }
    end
  end

  def errors_for(response)
    [response.dig("errorMessage", "error")].flatten.compact.map do |error|
      EbayRequest::ErrorItem.new(
        severity: error["severity"],
        code:     error["errorId"],
        message:  error["message"],
      )
    end
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

  FATAL_ERRORS = {
    21_917_053 => IAFTokenExpired,
  }.freeze
end
