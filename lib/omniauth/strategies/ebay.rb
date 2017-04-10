# frozen_string_literal: true
class OmniAuth::Strategies::Ebay
  include OmniAuth::Strategy

  args [:runame, :devid, :appid, :certid]

  option :runame,  nil
  option :devid,   nil
  option :appid,   nil
  option :certid,  nil
  option :site_id, "0"
  option :sandbox, true

  uid         { raw_info["EIASToken"] }
  credentials { { token: @auth_token, expires_at: @expires_at } }
  extra       { { raw_info: raw_info } }

  info do
    {
      user_id:    raw_info["UserID"],
      auth_token: @auth_token,
      email:      raw_info["Email"],
      full_name: full_name,
      first_name: parsed_name[0],
      last_name: parsed_name[1],
      eias_token: raw_info["EIASToken"]
    }
  end

  def request_phase
    configure unless EbayRequest.configured?
    session["omniauth.ebay.session_id"] = fetch_session_id
    redirect ebay.ebay_login_url(session["omniauth.ebay.session_id"])
  end

  def callback_phase
    response = fetch_token

    @auth_token = response["eBayAuthToken"]
    @expires_at = Time.parse(response["HardExpirationTime"]).to_i
    @user_info  = ebay.user(@auth_token)

    super
  end

  def configure
    EbayRequest.configure do |config|
      config.runame  = options.runame
      config.devid   = options.devid
      config.appid   = options.appid
      config.certid  = options.certid
      config.sandbox = options.sandbox
    end
  end

  def raw_info
    @user_info["User"]
  end

  def full_name
    @full_name ||= raw_info["RegistrationAddress"].try(:[], "Name")
  end

  def parsed_name
    @parsed_name ||= (full_name || "").split(" ", 2)
  end

  def ebay
    @ebay ||= EbayRequest::Auth.new(site_id: options.site_id)
  end

  def fetch_token
    ebay.token(session["omniauth.ebay.session_id"])
  end

  def fetch_session_id
    ebay.session_id["SessionID"]
  end
end
