module Spree
  class Gateway::MoipBase < Gateway
    delegate :url_helpers, to: 'Spree::Core::Engine.routes'

    preference :token, :string
    preference :key, :string

    has_many :moip_notifications, as: 'payment_method'

    after_create :register_notifications
    before_destroy :unregister_notifications

    def provider_class
      Spree::Moip
    end

    private

    def register_notifications
      return if moip_notifications.present?
      response = provider.api.notifications.create(
        events: ['PAYMENT.*'],
        target: url_helpers.moip_webhook_url(id),
        media: 'WEBHOOK'
      )
      Spree::MoipNotification.create(
        payment_method: self,
        moip_id: response.id,
        token: response.token
      )
    end

    def unregister_notifications
      moip_notifications.each do |notification|
        provider.api.notifications.delete notification.moip_id
        notification.destroy!
      end
    end
  end
end
