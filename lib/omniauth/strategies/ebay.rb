# frozen_string_literal: true

class OmniAuth::Strategies::Ebay
  include OmniAuth::Strategy

  args %i[runame :devid :appid :certid]

  option :runame,  nil
  option :devid,   nil
  option :appid,   nil
  option :certid,  nil
  option :site_id, "0"
  option :sandbox, true
  option :auth_method, :auth_n_auth

  uid         { ebay.uid }
  credentials { ebay.credentials }
  extra       { { raw_info: ebay.raw_info } }

  info        { ebay.info }

  def request_phase
    configure unless EbayRequest.configured?
    session["omniauth.ebay.session_id"] = ebay.session_id
    redirect ebay.ebay_login_url
  end

  def callback_phase
    ebay.session_id = session["omniauth.ebay.session_id"]
    super
  end

  def configure
    EbayRequest.configure do |config|
      config.runame      = options.runame
      config.devid       = options.devid
      config.appid       = options.appid
      config.certid      = options.certid
      config.sandbox     = options.sandbox
      config.auth_method = options.auth_method
    end
  end

  def ebay
    @ebay ||= begin
      params = { auth_method: options.auth_method, site_id: options.site_id }
      EbayRequest::Auth.new(params).adapter(request)
    end
  end
end
