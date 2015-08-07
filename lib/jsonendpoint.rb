require 'json'

module SteamWeb
  class JSONEndpoint < Endpoint
    def request(**options)
      check_success = options.include?(:check_success) ? options[:check_success] : false
      options.delete(:check_success) if options.include? :check_success

      body = super(options).body

      begin
        json_body = JSON.parse(body).symbolize_keys
      rescue JSON::ParserError
        raise InvalidResponseError.new self, body
      else
        if !json_body[:success] && check_success
          fail FailureResponseError.new self, body
        end
      end

      json_body
    end
  end
end
