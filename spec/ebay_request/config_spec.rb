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
end
