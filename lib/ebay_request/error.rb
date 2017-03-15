# frozen_string_literal: true
class EbayRequest::Error < StandardError
  def initialize(msg = "EbayRequest error", errors = {})
    super(msg)
    @errors = errors
  end

  attr_reader :errors
end
