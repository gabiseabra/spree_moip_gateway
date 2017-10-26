module SpreeMoipGateway
  mattr_accessor :register_webhooks
  mattr_accessor :register_profiles

  def self.config
    defaults!
    yield self
  end

  def self.defaults!
    @register_webhooks = false
    @register_profiles = false
  end
end
