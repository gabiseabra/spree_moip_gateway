module SpreeMoipGateway
  mattr_accessor :register_webhooks
  mattr_accessor :register_profiles

  def self.config
    defaults!
    yield self
  end

  def self.defaults!
    self.register_webhooks = false
    self.register_profiles = false
  end
end
