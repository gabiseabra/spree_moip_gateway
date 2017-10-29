module Spree
  class Moip::Response::Success < ActiveMerchant::Billing::Response
    attr_reader :response
    alias data response

    def initialize(response, order: nil, test_mode: false)
      @response = response
      @order = order
      super(true, response_message, {}, {
        authorization: response.try(:id),
        fraud_review: state == 'IN_ANALYSIS',
        test: test_mode
      })
    end

    def id
      @response.try(:id)
    end

    def state
      @response.try(:status)
    end

    private

    def response_message
      case state
      when 'WAITING' then Spree.t('moip.pending')
      when 'IN_ANALYSIS' then Spree.t('moip.in_analysis')
      else Spree.t('moip.success')
      end
    end
  end
end
