require 'moip2'
require 'recursive-open-struct'

module Spree::Moip
  class Client
    def initialize(options)
      @token = options[:token]
      @secret = options[:key]
      @test_mode = options[:test_mode]
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

    def order_token(options)
      order_id = options.order_id
      if order = Spree::MoipOrder.find_by(order: order_id)
        order.token
      else
        response = api.order.create Spree::Moip::Parse.order(options)
        raise 'Failed to create order token' unless response.success?
        Spree::MoipOrder.create(
          token: response.id,
          status: response.status,
          total: response.amount[:total],
          order: order_id
        )
        response.id
      end
    end

    def purchase(money, source, options)
      token = order_token(options)
      # api.payment.create( ... )
    end
  end
end
