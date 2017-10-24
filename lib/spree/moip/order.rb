module Spree
  class Moip::Order
    attr_reader :token, :total, :customer_id

    def initialize(response)
      @token = response.id
      @total = response.amount[:total]
      @customer_id = response.customer.id
    end
  end
end
