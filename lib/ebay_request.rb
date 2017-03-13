require "omniauth"
require "net/http"
require "gyoku"
require "multi_xml"
require "dry-initializer"

require "ebay_request/version"
require "ebay_request/site"
require "ebay_request/config"
require "ebay_request/base"
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
    attr_accessor :json_logger

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

    def log(options)
      log_info(options)
      log_warn(options)
      log_json(options)
    end

    # rubocop:disable Metrics/AbcSize
    def log_info(o)
      return if logger.nil?

      logger.info "[EbayRequest] | Url      | #{o[:url]}"
      logger.info "[EbayRequest] | Headers  | #{o[:headers]}"
      logger.info "[EbayRequest] | Body     | #{o[:request_payload]}"
      logger.info "[EbayRequest] | Response | #{fix_utf(o[:response_payload])}"
      logger.info "[EbayRequest] | Time     | #{o[:time]} #{o[:callname]}"
    end
    # rubocop:enable Metrics/AbcSize

    def log_warn(o)
      return if warn_logger.nil? || o[:warnings].empty?

      warn_logger.warn(
        "[EbayRequest] | #{o[:callname]} | #{o[:warnings].inspect}"
      )
    end

    def log_json(options)
      return if json_logger.nil?
      json_logger.log(options)
    end

    def fix_utf(response)
      response.encode(
        "UTF-8", undef: :replace, invalid: :replace, replace: " "
      )
    end
  end
end
