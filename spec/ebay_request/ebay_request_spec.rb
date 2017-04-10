# frozen_string_literal: true

require "spec_helper"

describe EbayRequest do
  describe "#configure/#config" do
    context ":default" do
      subject do
        EbayRequest.configure do |config|
          config.appid = "1"
          config.certid = "2"
          config.devid = "3"
          config.runame = "4"
        end
      end

      it "makes config instance" do
        expect(EbayRequest.config).to eq(subject)
      end
    end

    context ":sandbox" do
      subject do
        EbayRequest.configure(:sandbox) do |config|
          config.appid = "1"
          config.certid = "2"
          config.devid = "3"
          config.runame = "4"
          config.sandbox = true
        end
      end

      it "makes config instance" do
        expect(EbayRequest.config(:sandbox)).to eq(subject)
        expect(EbayRequest.config(:sandbox).sandbox).to eq(true)
      end
    end
  end
end
