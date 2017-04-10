# frozen_string_literal: true

class EbayRequest::Site
  KEYS = %w[
    globalid id name currency language domain code metric country gtc_available
    free_placement max_insertion_fee free_pictures subtitle_fee quantity_limits
  ].freeze

  attr_reader(*KEYS)

  def initialize(hash)
    @hash = hash
    @hash["code"] = @hash["globalid"].gsub("EBAY-", "")

    KEYS.each { |key| instance_variable_set(:"@#{key}", hash[key]) }
  end

  def to_hash
    @hash
  end
  alias to_h to_hash

  def gtc_available?
    return @gtc_available if [true, false].include? @gtc_available

    raise <<-MESSAGE.gsub(/^ +\|/, "")
      |We haven't checked whether GTC duration is available on the site #{@id}.
      |You should explore if GTC is supported by at least one of its categories (see https://developer.ebay.com/devzone/xml/docs/reference/ebay/GetCategoryFeatures.html)
      |Then you're welcome to make a PR with a resulting value (true|false) added to `config/sites.yml`
    MESSAGE
  end
end
