class EbayRequest::Site
  attr_reader :globalid, :id, :name, :currency, :language, :domain
  attr_reader :code, :metric

  def initialize(hash)
    %w(globalid id name currency language domain metric).each do |key|
      instance_variable_set(:"@#{key}", hash[key])
    end

    @code = globalid.gsub("EBAY-", "")
  end
end
