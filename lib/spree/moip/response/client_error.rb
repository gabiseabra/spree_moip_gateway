module Spree
  class Moip
    class Response::ClientError < Response
      attr_reader :data

      def initialize(data, test_mode: false)
        @data = data
        super(false, response_message, {}, { test: test_mode })
      end

      private

      def response_message
        if errors = @data.try(:errors)
          errors.map(&:description).join('; ')
        else
          Spree.t('moip.failure')
        end
      end
    end
  end
end
