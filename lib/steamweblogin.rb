require_relative './ext/hash.rb'

require_relative './errors.rb'
require_relative './endpoint.rb'
require_relative './jsonendpoint.rb'

require_relative './endpoints/getrsakey.rb'
require_relative './endpoints/dologin.rb'

module SteamWeb
  def self.login(username, password, **options)
    rsa_key = Endpoints::GetRSAKeyEndpoint.new.request username
    transfer = Endpoints::DoLoginEndpoint.new.request username, password, rsa_key, options

    transfer
  end
end
