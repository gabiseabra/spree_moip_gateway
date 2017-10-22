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
      order_id = options.order_id
      if order = Spree::MoipOrder.find_by(order: order_id)
        order
      else
        response = api.order.create Parse.order(options, customer_id: customer_id)
        throw :error, Response.new(self, response) unless response.success?
        Spree::MoipOrder.create(
          token: response.id,
          status: response.status,
          total: response.amount[:total],
          customer_id: response.customer.id,
          order: order_id
        )
      end
    end

    def purchase(money, source, options)
      catch(:error) do
        order = moip_order(options, customer_id: source.gateway_customer_profile_id)
        response = api.payment.create order.token, Parse.payment(options, source: source)
        source.gateway_customer_profile_id = order.customer_id
        source.gateway_payment_profile_id = response.funding_instrument.credit_card.id
        Response.new self, response
      end
    end
  end
end
