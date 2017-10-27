module Spree
  class Moip
    module Response
      def self.parse(provider, response, order: nil)
        options = { order: order, test_mode: provider.test_mode? }
        if response.success?
          Success.new response, **options
        elsif response.client_error?
          ClientError.new response, **options
        else
          raise ActiveMerchant::ConnectionError.new(response.to_s, nil)
        end
      end
    end
  end
end
