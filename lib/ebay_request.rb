require "ebay_request/version"
require "ebay_request/config"
require "ebay_request/finding"

module EbayRequest
  class << self
    attr_accessor :logger

    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end
  end
end
