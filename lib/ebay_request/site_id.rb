module EbayRequest::SiteId
  def initialize(config = :default, options = {})
    super
    options[:siteid] ||=
      EbayRequest::Config.site_id_from_globalid(options[:globalid]) || 0
  end
end
