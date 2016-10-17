require "omniauth"
require "net/http"
require "gyoku"
require "multi_xml"

require "ebay_request/version"
require "ebay_request/site"
require "ebay_request/config"
require "ebay_request/base"
require "ebay_request/xml"
require "ebay_request/site_id"
require "ebay_request/error"
require "ebay_request/finding"
require "ebay_request/shopping"
require "ebay_request/trading"
require "ebay_request/business_policies"
require "ebay_request/auth"
require "ebay_request/response"

require "omniauth/strategies/ebay"

module EbayRequest
  class << self
    attr_accessor :logger
    attr_accessor :warn_logger
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
      logger.info "[EbayRequest] | Response | #{fix_utf(response)}"
    end

    def log_time(callname, time)
      return if logger.nil?
      logger.info "[EbayRequest] | Callname + Time | #{time} #{callname}"
    end

    def log_warn(callname, message)
      return if warn_logger.nil?
      warn_logger.warn "[EbayRequest] | #{callname} | #{message}"
    end

    def fix_utf(response)
      response.encode(
        "UTF-8", undef: :replace, invalid: :replace, replace: " "
      )
    end
  end
end
