$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ebay_request"
require "webmock/rspec"
require "simplecov"

WebMock.disable_net_connect!
SimpleCov.start

RSpec.configure do |config|
  config.order = :random
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
