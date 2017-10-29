module Spree
  class Moip::Response::ClientError < ActiveMerchant::Billing::Response
    attr_accessor :response
    alias data response

    def initialize(response, test_mode: false, order:)
      @response = response
      super(false, response_message, {}, { test: test_mode })
    end

    private

    def response_message
      if errors = @response.try(:errors)
        errors.map(&:description).join('; ')
      else
        Spree.t('moip.failure')
      end
    end
  end
end
