require 'httpi'

require_relative './errors.rb'

HTTPI.log = false

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
      if options.include?(:url)
        uri = URI.parse options[:url]
      else
        uri = URI.parse url
      end

      request_params = options.include?(:params) ? params.merge(options[:params]) : params

      fail InvalidUrlError, self unless uri.is_a? URI::HTTP

      request = HTTPI::Request.new

      request.url = uri
      request.set_cookies options[:cookies] if options.include? :cookies
      request.follow_redirect = true

      if method == :get
        request.query = request_params

        request_method = HTTPI.method :get
      elsif method == :post
        request.body = request_params

        request_method = HTTPI.method :post
      else
        fail ArgumentError, 'method must be either get or post'
      end

      request_method.call request
    end

    def to_s
      @url
    end
  end
end
