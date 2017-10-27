module Spree
  class Gateway
    class MoipCredit < MoipBase
      delegate :create_customer, to: :provider

      def method
        'CREDIT_CARD'
      end

      def source_required?
        true
      end

      def payment_source_class
        Spree::CreditCard
      end

      def payment_profiles_supported?
        SpreeMoipGateway.register_profiles
      end

      def create_profile(payment)
        source = payment.source
        user = payment.order.user
        return unless user && !source.has_payment_profile? && user.moip_profile_ready?
        catch(:error) do
          profile = user.moip_gateway_profile(self)
          response = provider.create_credit_card(
            payment.source,
            customer_id: profile.moip_id
          )
          payment.source.update(
            gateway_customer_profile_id: profile.moip_id,
            gateway_payment_profile_id: response.credit_card.id,
            moip_brand: response.credit_card.brand
          )
        end
      end

      def disable_customer_profile(source)
        api.customer.delete_credit_card! source.gateway_payment_profile_id
      end
    end
  end
end
