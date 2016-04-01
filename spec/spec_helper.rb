$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ebay_request"
require "webmock/rspec"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.order = :random
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
