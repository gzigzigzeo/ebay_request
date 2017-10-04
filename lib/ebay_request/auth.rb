class EbayRequest::Auth
  extend Dry::Initializer::Mixin

  class UnknownAdapter < RuntimeError; end

  option :site_id
  option :auth_method, default: proc { :auth_n_auth }

  def adapter
    @adapter ||=
      case auth_method
      when :auth_n_auth
        require_relative "./auth/auth_n_auth"
        AuthNAuth.new(site_id: site_id)
      else
        raise UnknownAdapter, "#{auth_method} is unknown auth method"
      end
  end
end
