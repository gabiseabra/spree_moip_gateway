module SpreeMoipGateway
  mattr_accessor :register_webhooks

  def self.config
    yield self
  end
end
