class EbayRequest::Site
  attr_reader :globalid, :id, :name, :currency, :language

  def initialize(hash)
    @globalid = hash["globalid"]
    @id       = hash["id"]
    @name     = hash["name"]
    @currency = hash["currency"]
    @language = hash["language"]
  end
end
