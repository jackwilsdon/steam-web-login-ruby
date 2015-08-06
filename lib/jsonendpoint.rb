require 'json'

module SteamWeb
  class JSONEndpoint < Endpoint

    def require_field(body, field_name)
      return if body[:json_body].include? field_name

      fail InvalidResponseError.new self, body[:body], "missing field `#{field_name}' from response"
    end

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

      { body: body, json_body: json_body }
    end
  end
end
