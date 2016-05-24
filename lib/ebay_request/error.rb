class EbayRequest::Error < StandardError
  def initialize(msg = "EbayRequest error", response = "", codes = [])
    super(msg)
    @response = response
    @codes = codes
  end

  attr_reader :response, :codes
end
