require_relative '../endpoint.rb'

module SteamWeb
  module Endpoints
    class GetSessionIDEndpoint < Endpoint
      def initialize
        super 'https://store.steampowered.com', :get
      end

      def request(cookies, **options)
        options.recursive_merge! cookies: cookies

        response = super options

        cookie = response.cookies.find { |cookie| cookie.name == 'sessionid'}

        return nil if cookie.nil?

        { session_id: cookie.name_and_value.split('=').last, cookies: response.cookies }
      end
    end
  end
end
