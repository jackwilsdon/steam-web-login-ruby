require 'base64'

require_relative '../endpoint.rb'

module SteamWeb
  module Endpoints
    class DoLoginEndpoint < JSONEndpoint
      ENDPOINT_ADDRESS = 'https://steamcommunity.com/login/dologin/'

      OPTION_PARAMETER_MAP = {
        captcha_gid: :captchagid,
        captcha_text: :captcha_text,
        emailauth: :emailauth,
        emailauth_steamid: :emailsteamid
      }

      def initialize
        super ENDPOINT_ADDRESS, :get
      end

      def request(username, password, rsa_key, **options)
        encrypted_password = Base64.strict_encode64 rsa_key[:rsakey].public_encrypt(password)

        options.recursive_merge!({
          params: {
            username: username,
            password: encrypted_password,
            rsatimestamp: rsa_key[:rsatimestamp],
            twofactorcode: ''
          }
        })

        OPTION_PARAMETER_MAP.each do |source, dest|
          next unless options.include?(source) && !options[:params].include?(dest)

          options[:params][dest] = options[source]
          options.delete source
        end

        json = super options

        response = {
          captcha_needed: false,
          emailauth_needed: false,
          incorrect_login: false,
          transfer_url: "",
          transfer_parameters: {}
        }

        if json[:message] == "Incorrect login."
          response.merge! incorrect_login: true
        end

        if json[:captcha_needed]
          response.merge!({
            captcha_needed: true,
            captcha_gid: json[:captcha_gid]
          })
        end

        if json[:emailauth_needed]
          response.merge!({
            emailauth_needed: true,
            emailauth_domain: json[:emaildomain],
            emailauth_steamid: json[:emailsteamid]
          })
        end

        if json[:transfer_url]
          response.merge!({
            transfer_url: json[:transfer_url],
            transfer_parameters: json[:transfer_parameters]
          })
        end

        response
      end
    end
  end
end
