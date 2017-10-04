# frozen_string_literal: true

require_relative "../auth"
require "httparty"

class EbayRequest::Auth::OAuth
  attr_writer :session_id

  def initialize(request)
    @request = request
  end

  def session_id
    @session_id ||= SecureRandom.hex
  end

  def uid
    raw_info["EIASToken"]
  end

  def info
    {
      name:       full_name, # Required per https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema#schema-10-and-later
      user_id:    raw_info["UserID"],
      email:      raw_info["Email"],
      full_name:  full_name,
      first_name: parsed_name[0],
      last_name:  parsed_name[1],
      eias_token: raw_info["EIASToken"],
      country:    raw_info["RegistrationAddress"].try(:[], "Country"),
      nickname:   raw_info["UserID"],
    }
  end

  def credentials
    @credentials ||= begin
      now = Time.now
      response = request!(
        "https://api#{config.sandbox && '.sandbox'}.ebay.com/identity/v1/oauth2/token",
        grant_type:   "authorization_code",
        code:         @request.params["code"],
        redirect_uri: config.runame,
      )
      {
        token:                    response["access_token"],
        expires:                  true,
        expires_at:               (now + response["expires_in"]).to_i,
        refresh_token:            response["refresh_token"],
        refresh_token_expires_at: (now + response["refresh_token_expires_in"]).to_i,
      }
    end
  end

  def raw_info
    @raw_info ||= begin
      auth_headers = {"X-EBAY-API-IAF-TOKEN" => credentials[:token]}
      EbayRequest::Trading.new(headers: auth_headers).response!(
        "GetUser",
        DetailLevel: "ReturnAll",
      )["User"]
    end
  end

  def ebay_login_url(_ = {})
    scope = scopes.map { |s| "https://api.ebay.com/oauth/#{s}" }.join(" ")
    params = %W[
      client_id=#{CGI.escape(config.appid)}
      response_type=code
      redirect_uri=#{CGI.escape(config.runame)}
      scope=#{CGI.escape(scope)}
      state=#{session_id}
    ]

    "#{signin_endpoint}?#{params.join('&')}"
  end

  private

  def config
    EbayRequest.config
  end

  def scopes
    %w[
      api_scope
      api_scope/sell.marketing.readonly api_scope/sell.marketing
      api_scope/sell.inventory.readonly api_scope/sell.inventory
      api_scope/sell.account.readonly api_scope/sell.account
      api_scope/sell.fulfillment.readonly api_scope/sell.fulfillment
      api_scope/sell.analytics.readonly
    ]
  end

  def full_name
    @full_name ||= raw_info["RegistrationAddress"].try(:[], "Name")
  end

  def parsed_name
    @parsed_name ||= (full_name || "").split(" ", 2)
  end

  def signin_endpoint
    URI.parse(
      "https://signin#{config.sandbox && '.sandbox'}.ebay.com/authorize"
    )
  end

  def request!(url, data)
    response = HTTParty.post(
      url,
      body: data,
      basic_auth: { username: config.appid, password: config.certid },
      timeout: config.timeout,
    )
    raise response.body unless response.success?
    JSON.parse(response.body)
  end
end
