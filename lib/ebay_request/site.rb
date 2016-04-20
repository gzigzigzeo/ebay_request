class EbayRequest::Site
  attr_reader :globalid, :id, :name

  def initialize(hash)
    @globalid = hash["globalid"]
    @id       = hash["id"]
    @name     = hash["name"]
  end
end
