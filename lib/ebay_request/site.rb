class EbayRequest::Site
  attr_reader :globalid, :id, :name, :currency, :language, :domain
  attr_reader :code, :metric

  def initialize(hash)
    @hash = hash
    @hash["code"] = @hash["globalid"].gsub("EBAY-", "")

    %w(globalid id name currency language domain metric code).each do |key|
      instance_variable_set(:"@#{key}", hash[key])
    end
  end

  def to_hash
    @hash
  end
end
