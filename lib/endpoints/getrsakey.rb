require_relative '../endpoint.rb'

module SteamWeb
  module Endpoints
    class GetRSAKeyEndpoint < JSONEndpoint
      ENDPOINT_ADDRESS = 'https://steamcommunity.com/login/getrsakey'

      def initialize
        super ENDPOINT_ADDRESS, :post
      end

      def request(username, **options)
        options.recursive_merge!({
          params: {
            username: username
          },
          check_success: true
        })

        body = super(options)
        json = body[:json_body]

        require_field body, :publickey_exp
        require_field body, :publickey_mod
        require_field body, :timestamp

        key = OpenSSL::PKey::RSA.new
        key.e = OpenSSL::BN.new json[:publickey_exp].to_i(16)
        key.n = OpenSSL::BN.new json[:publickey_mod].to_i(16)

        { rsakey: key, rsatimestamp: json[:timestamp] }
      end
    end
  end
end