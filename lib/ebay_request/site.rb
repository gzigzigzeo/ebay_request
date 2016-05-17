class EbayRequest::Site
  attr_reader :globalid, :id, :name, :currency, :language, :domain, :code

  def initialize(hash)
    @globalid = hash["globalid"]
    @id       = hash["id"]
    @name     = hash["name"]
    @currency = hash["currency"]
    @language = hash["language"]
    @domain   = hash["domain"]
    @code     = globalid.gsub("EBAY-", "")
  end
end
