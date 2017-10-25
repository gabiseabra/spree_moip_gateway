module Spree
  class Moip::Response::ClientError < ActiveMerchant::Billing::Response
    def initialize(response, test_mode: false)
      @response = response
      super(false, message, {}, { test: test_mode })
    end

    private

    def message
      if errors = @response.try(:errors)
        errors.map(&:description).join('; ')
      else
        Spree.t('moip.failure')
      end
    end
  end
end
