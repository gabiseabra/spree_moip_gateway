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

      def source_required?
        false
      end
    end
  end
end
