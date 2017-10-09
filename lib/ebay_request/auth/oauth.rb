# frozen_string_literal: true

require_relative "../auth"

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
      country:    raw_info.dig("RegistrationAddress", "Country"),
      nickname:   raw_info["UserID"],
    }
  end

  def credentials
    @credentials ||= begin
      now = Time.now
      data = request!(
        token_endpoint,
        grant_type:   "authorization_code",
        code:         @request.params["code"],
        redirect_uri: config.runame,
      )
      {
        token:                    data["access_token"],
        expires:                  true,
        expires_at:               (now + data["expires_in"]).to_i,
        refresh_token:            data["refresh_token"],
        refresh_token_expires_at: (now + data["refresh_token_expires_in"]).to_i,
      }
    end
  end

  def raw_info
    @raw_info ||= begin
      auth_headers = { "X-EBAY-API-IAF-TOKEN" => credentials[:token] }
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
    @full_name ||= raw_info.dig("RegistrationAddress", "Name")
  end

  def parsed_name
    @parsed_name ||= full_name&.split(" ", 2) || []
  end

  def signin_endpoint
    URI.parse(
      "https://signin#{config.sandbox && '.sandbox'}.ebay.com/authorize",
    )
  end

  def token_endpoint
    environment_subdomain = config.sandbox ? ".sandbox" : ""
    "https://api#{environment_subdomain}.ebay.com/identity/v1/oauth2/token"
  end

  def request!(url, data)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.read_timeout = config.timeout
      http.use_ssl = uri.scheme == "https"
    end
    post = Net::HTTP::Post.new(uri.path)
    post.body = URI.encode_www_form(data)
    post.basic_auth config.appid, config.certid
    response = http.start { |r| r.request(post) }
    raise response.body unless response.code == "200"
    JSON.parse(response.body)
  end
end
