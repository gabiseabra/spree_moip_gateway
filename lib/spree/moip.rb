require 'moip2'
require 'recursive-open-struct'

module Spree
  class Moip
    def initialize(options)
      @token = options[:token]
      @secret = options[:key]
      @test_mode = options[:test_mode]
    end

    def test_mode?
      @test_mode
    end

    def auth
      @auth ||= Moip2::Auth::Basic.new(@token, @secret)
    end

    def client
      @client ||= Moip2::Client.new(@test_mode ? :sandbox : :production, auth)
    end

    def api
      @api ||= Moip2::Api.new(client)
    end

    def moip_order(options, customer_id:)
      response = api.order.create Parse.order(options, customer_id: customer_id)
      throw :error, Response.new(self, response) unless response.success?
      Spree::Moip::Order.new response
    end

    def purchase(money, source, options)
      payment(money, source, options)
    end

    def authorize(money, source, options)
      payment(money, source, options, delay_capture: true)
    end

    # Capture funds for pre-authorized transaction
    def capture(_, transaction_id, __)
      Response.new self, api.payment.capture(transaction_id)
    end

    def void(transaction_id, _)
      Response.new self, api.refund.create(transaction_id)
    end

    private

    def payment(_, source, options, delay_capture: false)
      catch(:error) do
        customer_id = source.try(:gateway_customer_profile_id)
        order = moip_order(options, customer_id: customer_id)
        request = Parse.payment(options, source: source)
        request[:delay_capture] = delay_capture
        response = api.payment.create order.token, request
        update_source source, order, response if response.success?
        create_transaction options, response if response.success?
        # TODO - Add adjustments if needed
        Response.new self, response
      end
    end

    def create_transaction(options, response)
      Spree::MoipTransaction.create(
        payment_id: options[:payment_id],
        transaction_id: response.id,
        state: response.status,
        total: response.amount.total,
        installments: response.installment_count,
        changed_at: DateTime.now
      )
    end

    def update_source(source, order, response)
      if source.is_a? Spree::CreditCard
        data = {}
        data[:gateway_customer_profile_id] = order.customer_id
        if credit_card = response.try(:funding_instrument).try(:credit_card)
          data[:gateway_payment_profile_id] = credit_card.id
        end
      end
      source.update(data) if data
    end
  end
end
