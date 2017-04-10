# frozen_string_literal: true

require "spec_helper"

describe EbayRequest do
  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  it "#configured?" do
    described_class.config_repository = nil
    expect(described_class.configured?).to eq(false)
  end
end
