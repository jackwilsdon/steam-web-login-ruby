module SteamWeb
  class Connection
    attr_reader :username, :session_id

    def initialize(username, session_id)
      @username = username
      @session_id = session_id
    end
  end
end
