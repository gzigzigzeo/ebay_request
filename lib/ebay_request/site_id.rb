module EbayRequest::SiteId
  def initialize(options = {})
    super
    options[:siteid] ||=
      EbayRequest.config.site_id_from_globalid(options[:globalid]) || 0
  end
end
