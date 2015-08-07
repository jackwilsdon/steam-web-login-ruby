require 'rubygems'
require 'bundler/setup'

require_relative './ext/hash.rb'

require_relative './errors.rb'
require_relative './endpoint.rb'
require_relative './jsonendpoint.rb'

require_relative './endpoints/getrsakey.rb'
require_relative './endpoints/dologin.rb'
require_relative './endpoints/transfer.rb'
require_relative './endpoints/getsessionid.rb'

module SteamWeb
  def self.login(username, password, **options)
    login_response = {
      captcha_needed: false,
      emailauth_needed: false,
      login_incorrect: false,
      login_success: false
    }

    rsa_key = Endpoints::GetRSAKeyEndpoint.new.request username
    transfer_data = Endpoints::DoLoginEndpoint.new.request username, password, rsa_key, options

    if transfer_data[:captcha_needed]
      login_response.merge!(
        captcha_needed: true,
        captcha_gid: transfer[:captcha_gid]
      )
    end

    if transfer_data[:emailauth_needed]
      login_response.merge!(
        emailauth_needed: true,
        emailauth_domain: transfer_data[:emailauth_domain],
        emailauth_steamid: transfer_data[:emailauth_steamid]
      )
    end

    login_response[:login_incorrect] = true if transfer_data[:incorrect_login]

    if login_response[:captcha_needed] || login_response[:emailauth_needed] || login_response[:login_incorrect]
      return login_response
    end

    cookies = Endpoints::TransferEndpoint.new.request transfer_data[:transfer_url], transfer_data[:transfer_parameters]
    session = Endpoints::GetSessionIDEndpoint.new.request cookies

    unless session.include? :session_id
      login_response.merge!(
        login_success: true,
        login_session_id: session[:session_id],
        login_cookies: session[:cookies]
      )
    end

    login_response
  end
end
