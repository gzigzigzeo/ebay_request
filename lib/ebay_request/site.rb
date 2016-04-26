class EbayRequest::Site
  attr_reader :globalid, :id, :name, :currency

  def initialize(hash)
    @globalid = hash["globalid"]
    @id       = hash["id"]
    @name     = hash["name"]
    @currency = hash["currency"]
  end
end
