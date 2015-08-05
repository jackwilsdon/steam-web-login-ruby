module SteamWeb
  class EndpointError < StandardError
    attr_reader :endpoint

    def initialize(endpoint, message = self.class.name)
      super message

      @endpoint = endpoint
    end
  end

  class InvalidUrlError < EndpointError
    def initialize(endpoint, message = "invalid url `#{endpoint.url}'")
      super endpoint, message
    end
  end

  class ResponseError < EndpointError
    attr_reader :response_body

    def initialize(endpoint, response_body = nil, message = self.class.name)
      super endpoint, message

      @response_body = response_body
    end
  end

  class InvalidResponseError < ResponseError
    def initialize(endpoint, response_body = nil, message = 'invalid response')
      super endpoint, response_body, message
    end
  end

  class FailureResponseError < ResponseError
    def initialize(endpoint, response_body = nil, message = 'response was not successful')
      super endpoint, response_body, message
    end
  end
end
