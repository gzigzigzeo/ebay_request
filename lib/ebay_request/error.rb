class EbayRequest::Error < StandardError
  def initialize(msg = "EbayRequest error", response = "")
    super(msg)
    @response = response
  end

  attr_reader :response
end
