# frozen_string_literal: true

class EbayRequest::Shopping < EbayRequest::Base
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
      "X-EBAY-API-APP-ID" => config.appid,
      "X-EBAY-API-VERSION" => config.version.to_s,
      "X-EBAY-API-CALL-NAME" => callname,
      "X-EBAY-API-REQUEST-ENCODING" => "XML",
      "X-EBAY-API-SITE-ID" => siteid.to_s
    )
  end

  def errors_for(response)
    [response["Errors"]].flatten.compact.map do |error|
      EbayRequest::ErrorItem.new(
        severity: error["SeverityCode"],
        code:     error["ErrorCode"],
        message:  error["LongMessage"],
        params:   Hash[[error["ErrorParameters"]].flatten.compact.map do |p|
          [p["ParamID"], p["Value"]]
        end],
      )
    end
  end

  FATAL_ERRORS = {}.freeze
end
