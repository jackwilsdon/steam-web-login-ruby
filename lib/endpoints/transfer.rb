require_relative '../endpoint.rb'

module SteamWeb
  module Endpoints
    class TransferEndpoint < Endpoint
      def initialize
        super nil, :post
      end

      def request(transfer_url, transfer_parameters, **options)
        options.recursive_merge! url: transfer_url

        options.recursive_merge! params: transfer_parameters

        response = super options

        response.cookies
      end
    end
  end
end
