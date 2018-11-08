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
  config.example_status_persistence_file_path = ".rspec_status"
end

RSpec::Matchers.define :contain_error do |code:, message: nil, params: nil|
  match do |errors|
    expect(errors.size).to be_positive
    error = errors.find { |e| e.code == code }
    expect(error).to be
    expect(error.message).to eq(message) if message
    expect(error.params).to match(params) if params
    expect(error.severity).to eq("Error")
  end
end

RSpec::Matchers.define :contain_warning do |code:, message: nil, params: nil|
  match do |errors|
    expect(errors.size).to be_positive
    error = errors.find { |e| e.code == code }
    expect(error).to be
    expect(error.message).to eq(message) if message
    expect(error.params).to match(params) if params
    expect(error.severity).to eq("Warning")
  end
end
