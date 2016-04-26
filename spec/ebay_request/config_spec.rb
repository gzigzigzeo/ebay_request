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

      expect { subject.validate! }.to_not raise_error
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

    it "returns currency for 215" do
      expect(described_class.sites_by_id[215].currency).to eq("RUB")
    end
  end
end
