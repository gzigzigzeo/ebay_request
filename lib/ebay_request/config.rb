# frozen_string_literal: true
class EbayRequest::Config
  attr_accessor :appid
  attr_accessor :certid
  attr_accessor :devid
  attr_accessor :runame

  attr_accessor :sandbox
  attr_accessor :version
  attr_accessor :timeout
  attr_accessor :auth_method
  attr_accessor :oauth_scopes

  alias sandbox? sandbox

  def initialize
    @sandbox ||= true
    @version ||= 941
    @timeout ||= 60
  end

  def validate!
    %w(appid certid devid runame).each do |attr|
      value = public_send(attr)
      raise "Set EbayRequest.config.#{attr}" if value.nil? || value.empty?
    end
  end

  class << self
    def globalid_from_site_id(site_id)
      (site = sites_by_id[site_id]) && site.globalid
    end

    def site_id_from_globalid(globalid)
      (site = sites_by_globalid[globalid.to_s.upcase]) && site.id
    end

    def site_id_from_name(name)
      (site = sites_by_name[name]) && site.id
    end

    def sites
      @sites ||=
        YAML.load_file(
          File.join(File.dirname(__FILE__), "../../config/sites.yml")
        ).map { |h| EbayRequest::Site.new h }
    end

    def sites_by_id
      @sites_by_id ||= Hash[sites.map { |s| [s.id, s] }]
    end

    def sites_by_globalid
      @sites_by_globalid ||= Hash[sites.map { |s| [s.globalid, s] }]
    end

    def sites_by_name
      @sites_by_name ||= Hash[sites.map { |s| [s.name, s] }]
    end
  end
end
