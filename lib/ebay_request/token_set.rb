require "httparty"

class EbayRequest::TokenSet
  extend Dry::Initializer::Mixin

  class RefreshTokenExpired < EbayRequest::Error; end

  option :access_token
  option :access_token_expires_at
  option :refresh_token
  option :refresh_token_expires_at
  option :on_refresh, optional: true

  def access_token
    refresh! if access_token_expires_at < Time.now
    @access_token
  end

  def refresh!
    now = Time.now
    raise RefreshTokenExpired if refresh_token_expires_at < now
    response = HTTParty.post(
        "https://api#{EbayRequest.config.sandbox? ? ".sandbox" : "" }.ebay.com/identity/v1/oauth2/token",
        body: { grant_type: "refresh_token", refresh_token: refresh_token },
        basic_auth: { username: EbayRequest.config.appid, password: EbayRequest.config.certid },
        timeout: EbayRequest.config.timeout,
    )
    raise response.body unless response.success?
    data = JSON.parse(response.body)

    @access_token = data["access_token"]
    @access_token_expires_at = (now + data["expires_in"])

    on_refresh&.call(@access_token, @access_token_expires_at)
  end
end
