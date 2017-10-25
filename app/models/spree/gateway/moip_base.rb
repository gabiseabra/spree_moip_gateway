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

    def purchase(money, source, options)
      response = provider.purchase(money, source, options)
      create_transaction options, response if response.success?
      response
    end

    def authorize(money, source, options)
      response = provider.authorize(money, source, options)
      create_transaction options, response if response.success?
      response
    end

    private

    def create_transaction(options, response)
      Spree::MoipTransaction.create(
        payment_id: options[:payment_id],
        transaction_id: response.authorization,
        state: response.state,
        total: response.total,
        installments: response.installment_count,
        changed_at: DateTime.now
      )
    end

    def register_notifications
      return if !SpreeMoipGateway.register_webhooks || moip_notifications.present?
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
