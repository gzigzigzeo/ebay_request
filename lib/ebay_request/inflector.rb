module EbayRequest::Inflector
  extend self

  def camelcase_lower(input)
    input = input.to_s
    return unless input.length.positive?
    dry_inflector.camelize(input).tap do |result|
      result[0] = result[0].downcase
    end
  end

  private

  def dry_inflector
    @dry_inflector ||= Dry::Inflector.new
  end
end
