module Spree
  class Gateway
    class MoipCredit < MoipBase
      def purchase(money, source, options)
        response = super(money, source, options)
        update_source source, response if response.success?
        response
      end

      def authorize(money, source, options)
        response = super(money, source, options)
        update_source source, response if response.success?
        response
      end
    end

    private

    def update_source(source, response)
      if source.is_a? Spree::CreditCard
        data = {}
        data[:gateway_customer_profile_id] = response.customer_id
        data[:gateway_payment_profile_id] = response.credit_card_id
      end
      source.update(data) if data
    end
  end
end
