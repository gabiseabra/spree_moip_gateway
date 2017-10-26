module Spree
  class Gateway::MoipBase < Gateway
    preference :token, :string
    preference :key, :string

    delegate :api, to: :provider

    has_many :moip_notifications, as: 'payment_method'

    after_create :register_webhooks
    before_destroy :unregister_webhooks

    METHODS = %w[CREDIT_CARD BOLETO ONLINE_BANK_DEBIT WALLET].freeze

    def provider_class
      Spree::Moip
    end

    def provider
      raise NotImplementedError, 'Miop gateway must implement #method' unless respond_to?(:method)
      raise "Unknown payment method #{method}" unless METHODS.include?(method)
      Spree::Moip.new options, method
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

    def register_webhooks(force = false)
      return unless (force || SpreeMoipGateway.register_webhooks) && !moip_notifications.present?
      Spree::MoipNotification.create(
        events: ['PAYMENT.*'],
        payment_method: self
      )
    end

    def unregister_webhooks
      moip_notifications.each do |notification|
        notification.destroy!
      end
    end

    private

    def create_transaction(options, response)
      Spree::MoipTransaction.create(
        payment_id: options[:payment_id],
        transaction_id: response.authorization,
        state: response.state,
        total: response.total,
        installments: response.installment_count,
        moip_updated_at: DateTime.parse(response.updated_at)
      )
    end
  end
end
