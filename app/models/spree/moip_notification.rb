class Spree::MoipNotification < Spree::Base
  delegate :url_helpers, to: 'Spree::Core::Engine.routes'

  belongs_to :payment_method, polymorphic: true

  has_secure_token

  serialize :events

  before_create :register_webhook
  before_destroy :unregister_webhook

  private

  def register_webhook
    response = payment_method.api.notifications.create(
      events: events,
      target: url_helpers.moip_webhook_url(token),
      media: 'WEBHOOK'
    )
    self.moip_id = response.id
    self.moip_token = response.token
  end

  def unregister_webhook
    payment_method.api.notifications.delete moip_id
  end
end
