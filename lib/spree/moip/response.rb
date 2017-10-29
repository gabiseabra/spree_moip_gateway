module Spree
  class Moip
    class Response < ActiveMerchant::Billing::Response
      def self.parse(provider, response)
        options = { test_mode: provider.test_mode? }
        # Discard sensitive request data
        data = RecursiveOpenStruct.new response.to_hash, recurse_over_arrays: true
        if response.success?
          Success.new data, **options
        elsif response.client_error?
          ClientError.new data, **options
        else
          raise ActiveMerchant::ConnectionError.new(response.to_s, nil)
        end
      end
    end
  end
end
