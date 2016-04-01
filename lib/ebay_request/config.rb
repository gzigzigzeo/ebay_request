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
      raise "Set EbayRequest.config.#{attr}" if public_send(attr).blank?
    end
  end
end
