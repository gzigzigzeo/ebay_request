class EbayRequest::Site
  KEYS = %w(
    globalid id name currency language domain code metric country
    free_placement max_insertion_fee free_pictures subtitle_fee quantity_limits
  ).freeze

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
end
