# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ebay_request"
require "webmock/rspec"
require "simplecov"
require "pry"

WebMock.disable_net_connect!
SimpleCov.start

RSpec.configure do |config|
  config.order = :random
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
