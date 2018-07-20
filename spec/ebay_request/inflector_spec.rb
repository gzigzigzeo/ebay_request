# frozen_string_literal: true

require "spec_helper"

describe EbayRequest::Inflector do
  describe ".camelcase_lower" do
    subject { described_class.camelcase_lower(input) }

    context "with a string" do
      let(:input)  { "foo_bar_baz" }
      let(:output) { "fooBarBaz" }

      it { is_expected.to eq output }
    end

    context "with a symbol" do
      let(:input)  { :foo_bar_baz }
      let(:output) { "fooBarBaz" }

      it { is_expected.to eq output }
    end
  end
end
