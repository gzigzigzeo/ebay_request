# frozen_string_literal: true

# A single error from many returned in API response
class EbayRequest::ErrorItem
  extend Dry::Initializer

  option :code,     proc(&:to_i), comment: "Numeric error identifier"
  option :message,  proc(&:to_s), comment: "Human-readable error description"
  option :severity, proc(&:to_s), comment: "Either +Error+ of +Warning+"
  option :params,   proc(&:to_h), default: -> { {} }, comment: "Variable parts of message"

  def self.new(source)
    super(source.to_h.transform_keys(&:to_sym))
  end

  alias to_s message

  def inspect
    "#<#{self.class.name} #{severity} #{code}: #{message.inspect}>"
  end
end
