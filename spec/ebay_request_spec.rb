require "spec_helper"

describe EbayRequest do
  it "has a version number" do
    expect(EbayRequest::VERSION).not_to be nil
  end
end
