module SpreeMoipGateway
  mattr_accessor :register_webhooks

  def self.config
    defaults!
    yield self
  end

  def self.defaults!
    @register_webhooks = false
  end
end
