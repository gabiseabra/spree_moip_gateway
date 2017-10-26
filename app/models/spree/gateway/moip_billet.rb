module Spree
  class Gateway
    class MoipBillet < MoipBase
      preference :valid_days, :integer, default: 3
      preference :instruction_1, :text
      preference :instruction_2, :text
      preference :instruction_3, :text

      def method
        'BOLETO'
      end

      def auto_capture?
        false
      end

      def source_required?
        true
      end

      def payment_source_class
        Spree::MoipBillet
      end

      protected

      def after_payment(response, source, _)
        data = response.data
        source.update(
          url: data._links.pay_boleto.print_href,
          expires_at: Date.parse(data.funding_instrument.boleto.expiration_date)
        )
      end
    end
  end
end
