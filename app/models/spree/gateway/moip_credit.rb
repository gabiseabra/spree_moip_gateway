module Spree
  class Gateway
    class MoipCredit < MoipBase
      delegate :create_customer, to: :provider

      def payment_profiles_supported?
        SpreeMoipGateway.register_profiles
      end

      def create_profile(payment)
        return unless (user = payment.order.user) && user.moip_profile_ready?
        catch(:error) do
          cvc = 
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
    end
  end
end
