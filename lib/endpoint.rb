require 'net/http'

require_relative './errors.rb'

module SteamWeb
  class Endpoint
    attr_reader :url
    attr_reader :method
    attr_reader :params

    def initialize(url, method = :get, params = {})
      @url = url
      @method = method
      @params = params
    end

    def request(**options)
      uri = URI.parse url
      request_params = options.include?(:params) ? params.merge(options[:params]) : params

      fail InvalidUrlError, self unless uri.is_a? URI::HTTP

      if method == :get
        uri.query = URI.encode_www_form request_params

        response = Net::HTTP.get_response uri
      elsif method == :post
        response = Net::HTTP.post_form uri, request_params
      else
        fail ArgumentError, 'method must be either get or post'
      end

      response.body
    end

    def to_s
      @url
    end
  end
end
