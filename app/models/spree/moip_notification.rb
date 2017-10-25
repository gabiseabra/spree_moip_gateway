class Spree::MoipNotification < Spree::Base
  delegate :url_helpers, to: 'Spree::Core::Engine.routes'

  belongs_to :payment_method, polymorphic: true

  serialize :events

  before_create :register_webhook
  before_destroy :unregister_webhook

  private

  def register_webhook
    response = payment_method.provider.api.notifications.create(
      events: events,
      target: url_helpers.moip_webhook_url(payment_method.id),
      media: 'WEBHOOK'
    )
    self.moip_id = response.id
    self.token = response.token
  end

  def unregister_webhook
    payment_method.provider.api.notifications.delete moip_id
  end
end
