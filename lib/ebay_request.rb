require "ebay_request/version"
require "ebay_request/config"
require "ebay_request/base"
require "ebay_request/finding"
require "net/http"
require "json"

module EbayRequest
  class << self
    attr_accessor :logger

    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end

    def log(url, headers, body, response)
      return if logger.blank?

      logger.info "[EbayRequest] | Url      | #{url}"
      logger.info "[EbayRequest] | Headers  | #{headers}"
      logger.info "[EbayRequest] | Body     | #{body}"
      logger.info "[EbayRequest] | Response | #{response}"
    end
  end
end
