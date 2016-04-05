class EbayRequest::Config
  attr_accessor :appid
  attr_accessor :certid
  attr_accessor :devid
  attr_accessor :runame

  attr_accessor :sandbox
  attr_accessor :version
  attr_accessor :timeout

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

  def site_from_globalid(globalid)
    sites[globalid.to_s.upcase]
  end

  private

  def sites
    @sites ||= YAML.load_file(
      File.join(File.dirname(__FILE__), "../../config/sites.yml")
    )
  end
end
