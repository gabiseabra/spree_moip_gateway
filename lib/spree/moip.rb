require 'moip2'
require 'recursive-open-struct'

module Spree
  class Moip
    def initialize(options, method = 'CREDIT_CARD')
      @method = method
      @token = options[:token]
      @secret = options[:key]
      @test_mode = options[:test_mode]
      @valid_days = options[:valid_days]
      @instructions = {
        first: options[:instruction_1],
        second: options[:instruction_2],
        third: options[:instruction_3]
      }
    end

    def test_mode?
      @test_mode
    end

    def billet_options
      {
        expiration_date: @valid_days.days.from_now,
        instructions: @instructions
      }
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

    def create_customer(user, token:)
      response = api.customer.create Parse.customer(user, token: token)
      throw :error, Response.parse(self, response) unless response.success?
      response
    end

    def create_credit_card(source, customer_id:)
      response = api.customer.add_credit_card customer_id, Parse.credit_card(source, store: true)
      throw :error, Response.parse(self, response) unless response.success?
      response
    end

    def create_order(options, customer_id: nil)
      response = api.order.create Parse.order(options, customer_id: customer_id)
      throw :error, Response.parse(self, response) unless response.success?
      response
    end

    def purchase(money, source, options)
      payment(money, source, options)
    end

    def authorize(money, source, options)
      payment(money, source, options, delay_capture: true)
    end

    # Capture funds for pre-authorized transaction
    def capture(_, transaction_id, __)
      Response.parse self, api.payment.capture(transaction_id)
    end

    def void(transaction_id, _, __)
      Response.parse self, api.refund.create(transaction_id)
    end

    private

    def payment(_, source, options, delay_capture: false)
      catch(:error) do
        customer_id = source.try(:gateway_customer_profile_id)
        order = create_order(options, customer_id: customer_id)
        source = billet_options if @method == 'BOLETO'
        request = Parse.payment(options, source: source, method: @method)
        request[:delay_capture] = delay_capture if @method == 'CREDIT_CARD'
        response = api.payment.create order.id, request
        Response.parse self, response, order: order
      end
    end
  end
end
