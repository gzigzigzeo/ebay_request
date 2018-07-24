# frozen_string_literal: true

# A single error from many returned in API response
class EbayRequest::ErrorItem
  attr_reader :code, :message, :severity, :params

  # @param code     [Integer]             Numeric error identifier
  # @param message  [String]              Human-readable error description
  # @param severity [String]              Either +Error+ of +Warning+
  # @param params   [Hash<String,String>] Variable parts of message
  def initialize(code:, message:, severity:, params: {})
    @code     = Integer(code)
    @message  = message
    @severity = severity
    @params   = params
  end

  def to_s
    message
  end

  def inspect
    "#<#{self.class.name} #{severity} #{code}: #{message.inspect}>"
  end
end
