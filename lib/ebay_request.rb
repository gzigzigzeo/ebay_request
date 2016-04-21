require "ebay_request/version"
require "ebay_request/site"
require "ebay_request/config"
require "ebay_request/xml"
require "ebay_request/site_id"
require "ebay_request/base"
require "ebay_request/finding"
require "ebay_request/shopping"
require "ebay_request/trading"
require "ebay_request/auth"
require "ebay_request/error"
require "net/http"
require "gyoku"
require "multi_xml"

module EbayRequest
  class << self
    attr_accessor :logger
    attr_accessor :config_repository

    def config(key = nil)
      @config_repository ||= {}
      @config_repository[key || :default] ||= Config.new
    end

    def configure(key = nil)
      yield(config(key)) && config(key)
    end

    def configured?
      !@config_repository.nil?
    end

    def log(url, headers, body, response)
      return if logger.nil?

      logger.info "[EbayRequest] | Url      | #{url}"
      logger.info "[EbayRequest] | Headers  | #{headers}"
      logger.info "[EbayRequest] | Body     | #{body}"
      logger.info "[EbayRequest] | Response | #{response}"
    end
  end
end
