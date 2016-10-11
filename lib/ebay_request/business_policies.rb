class EbayRequest::BusinessPolicies < EbayRequest::Xml
  include EbayRequest::SiteId

  private

  SERVICE_NAME = "SellerProfilesManagementService".freeze

  def payload(callname, request)
    key_converter = -> (key) { key.camelize(:lower) }
    request = Gyoku.xml(request, key_converter: key_converter)

    %(<?xml version="1.0" encoding="utf-8"?>\
<#{callname}Request xmlns="http://www.ebay.com/marketplace/selling">\
#{request}</#{callname}Request>)
  end

  def endpoint
    "https://svcs%{sandbox}.ebay.com/services/selling/v1/#{SERVICE_NAME}"
  end

  def headers(callname)
    super.merge(
      "Content-Type" => "text/xml",
      "X-EBAY-SOA-SECURITY-TOKEN" => options[:token],
      "X-EBAY-SOA-SERVICE-NAME" => SERVICE_NAME,
      "X-EBAY-SOA-OPERATION-NAME" => callname,
      "X-EBAY-SOA-CONTENT-TYPE" => "XML",
      "X-EBAY-SOA-GLOBAL-ID" => options[:siteid].to_s
    )
  end

  def errors_for(r)
    [r.dig("errorMessage", "error")]
      .flatten
      .compact
      .map { |e| [e["severity"], e["errorId"], e["message"]] }
  end
end
