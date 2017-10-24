module Spree
  class Moip::Response < ActiveMerchant::Billing::Response
    def initialize(provider, response)
      if response.success?
        options = success_options response
        message = success_options response
      else
        options = failure_options response
        message = failure_message response
      end
      options[:test] = provider.test_mode?
      super(response.success?, message, {}, options)
    end

    private

    def success_options(response)
      {
        authorization: response.id,
        fraud_review: response.status == 'IN_ANALYSIS'
      }
    end

    def failure_options(response)
      {}
    end

    def success_message(response)
      case response.status
      when 'WAITING' then Spree.t('moip.pending')
      when 'IN_ANALYSIS' then Spree.t('moip.in_analysis')
      else Spree.t('moip.success')
      end
    end

    def failure_message(response)
      if errors = response.try(:errors)
        errors.map(&:description).join('; ')
      else
        Spree.t('moip.failure')
      end
    end
  end
end
