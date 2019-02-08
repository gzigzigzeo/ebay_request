# frozen_string_literal: true

require "spec_helper"

describe EbayRequest::Config do
  context "#validate!" do
    it "fails if values missing" do
      expect { subject.validate! }.to raise_error(/appid/)
    end

    it "succeeds if everything present" do
      subject.appid = "1"
      subject.certid = "2"
      subject.devid = "3"
      subject.runame = "4"

      expect { subject.validate! }.not_to raise_error
    end
  end

  context "#site_id_from_globalid" do
    it "returns 215 for EBAY-RU" do
      expect(described_class.site_id_from_globalid("EBAY-RU")).to eq(215)
    end
  end

  context "#site_id_from_name" do
    it "returns 215 for Russia" do
      expect(described_class.site_id_from_name("Russia")).to eq(215)
    end
  end

  context "#sites_by_id" do
    it "returns EBAY-RU for 215" do
      expect(described_class.sites_by_id[215].globalid).to eq("EBAY-RU")
    end

    it "returns RU for 215" do
      expect(described_class.sites_by_id[215].code).to eq("RU")
    end

    it "returns currency for 215" do
      expect(described_class.sites_by_id[215].currency).to eq("RUB")
    end

    it "returns language for 215" do
      expect(described_class.sites_by_id[215].language).to eq("ru")
    end

    it "returns language for 77" do
      expect(described_class.sites_by_id[77].subtitle_fee).to eq(0.5)
    end

    it "returns gtc_available for 215" do
      expect(described_class.sites_by_id[215]).to be_gtc_available
    end

    it "returns gtc_available for 71" do
      expect(described_class.sites_by_id[71]).to be_gtc_available
    end

    it "raises when gtc availability asked for 207" do
      expect { described_class.sites_by_id[207].gtc_available? }
        .to raise_error(StandardError)
    end
  end
end
