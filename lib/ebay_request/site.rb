class EbayRequest::Site
  attr_reader :globalid, :id, :name, :currency, :language, :domain
  attr_reader :code, :metric

  def initialize(hash)
    @hash = hash

    %w(globalid id name currency language domain metric).each do |key|
      instance_variable_set(:"@#{key}", hash[key])
    end

    @code = globalid.gsub("EBAY-", "")
  end

  def to_hash
    @hash
  end
end
