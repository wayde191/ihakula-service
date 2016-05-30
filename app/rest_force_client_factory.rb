require 'restforce'

class RestForceClientFactory

  def self.create(settings)
    Restforce.new :host => settings.salesforce_host,
                  :username => settings.salesforce_username,
                  :password => settings.salesforce_password,
                  :security_token => settings.salesforce_security_token,
                  :client_id => settings.salesforce_client_id,
                  :client_secret => settings.salesforce_client_secret

  end
end