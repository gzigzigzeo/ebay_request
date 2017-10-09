# frozen_string_literal: true

require "httparty"

# Holds access token from OAuth method for using with all eBay APIs
# Retrieves new access token every time when current become outdated.
class EbayRequest::TokenSet
  extend Dry::Initializer

  class RefreshTokenExpired < EbayRequest::Error; end
  class RefreshTokenInvalid < EbayRequest::Error; end

  option :access_token
  option :access_token_expires_at
  option :refresh_token
  option :refresh_token_expires_at
  option :on_refresh, optional: true

  # @!method initialize(options)
  #   @option options [String] access_token
  #     Short-living access token
  #   @option options [Time]   access_token_expires_at
  #     Timestamp of the +access_token+ expiry time.
  #   @option options [String] refresh_token
  #     Long-living token to get new access tokens
  #   @option options [Time]   refresh_token_expires_at
  #     Timestamp of the +refresh_token+ expiry time.
  #   @option options [#call]  on_refresh
  #     Callback. Will be called after successful renewal with two arguments:
  #     new access token and its expiration time

  # Returns access token (retrieves and returns new one if it has expired)
  def access_token
    refresh! if access_token_expires_at <= Time.now
    @access_token
  end

  # Requests new access token, use +access_token+ to get its contents.
  def refresh!
    now = Time.now
    raise RefreshTokenExpired if refresh_token_expires_at <= now

    data = refresh_token_request!
    raise(RefreshTokenInvalid, data["error_description"]) if data.key?("error")

    @access_token = data["access_token"]
    @access_token_expires_at = (now + data["expires_in"])

    on_refresh&.call(@access_token, @access_token_expires_at)
  end

  private

  def refresh_token_request!
    response = HTTParty.post(
      token_endpoint,
      body: { grant_type: "refresh_token", refresh_token: refresh_token },
      basic_auth: { username: config.appid, password: config.certid },
      timeout: config.timeout,
    )
    return JSON.parse(response.body) if [200, 400].include?(response.code)
    raise EbayRequest::Error, "Can't refresh access token: #{response.body}"
  end

  def token_endpoint
    environment = config.sandbox? ? ".sandbox" : ""
    "https://api#{environment}.ebay.com/identity/v1/oauth2/token"
  end

  def config
    EbayRequest.config
  end
end
