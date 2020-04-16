# frozen_string_literal: true

# A single error from many returned in API response
class EbayRequest::ErrorItem
  extend Dry::Initializer

  option :code, proc(&:to_s), comment: "Numeric error identifier"
  option :message, proc(&:to_s), comment: "Human-readable error description"
  option :severity, proc(&:to_s), comment: "Either +Error+ of +Warning+"
  option :params, proc(&:to_h), default: -> { {} }, comment: "Variable parts of message"

  def self.new(source)
    source = source.to_h.each_with_object({}) { |(k, v), obj| obj[k.to_sym] = v }
    super(source)
  end

  alias :to_s :message

  def inspect
    "#<#{self.class.name} #{severity} #{code}: #{message.inspect}>"
  end
end
