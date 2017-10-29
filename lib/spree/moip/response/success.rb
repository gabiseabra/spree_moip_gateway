module Spree
  class Moip
    class Response::Success < Response
      attr_reader :data

      def initialize(data, test_mode: false)
        @data = data
        super(true, response_message, {}, {
          authorization: data.try(:id),
          fraud_review: state == 'IN_ANALYSIS',
          test: test_mode
        })
      end

      def id
        @data.try(:id)
      end

      def state
        @data.try(:status)
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
end
