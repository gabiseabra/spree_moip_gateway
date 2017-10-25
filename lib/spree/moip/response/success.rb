module Spree
  class Moip::Response::Success < ActiveMerchant::Billing::Response
    def initialize(response, order: nil, test_mode: false)
      @response = response
      @order = order
      super(true, message, {}, {
        authorization: response.try(:id),
        fraud_review: state == 'IN_ANALYSIS',
        test: test_mode
      })
    end

    def state
      @response.try(:status)
    end

    def total
      @response.try(:amount).try(:total)
    end

    def installment_count
      @response.try(:installment_count)
    end

    def credit_card_id
      @response.try(:funding_instrument).try(:credit_card).try(:id)
    end

    def customer_id
      @order.try(:customer_id)
    end

    private

    def message
      case state
      when 'WAITING' then Spree.t('moip.pending')
      when 'IN_ANALYSIS' then Spree.t('moip.in_analysis')
      else Spree.t('moip.success')
      end
    end
  end
end
