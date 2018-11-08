# frozen_string_literal: true

class EbayRequest::Error < StandardError
  def initialize(msg = "EbayRequest error", errors: [], warnings: [])
    super(msg)
    @errors   = errors
    @warnings = warnings
  end

  # @!attribute errors   [Array<EbayRequest::ErrorItem>] fatal errors
  # @!attribute warnings [Array<EbayRequest::ErrorItem>] non-fatal errors
  attr_reader :errors, :warnings
end
