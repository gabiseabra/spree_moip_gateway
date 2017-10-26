module Spree
  Payment.class_eval do
    has_one :moip_transaction

    alias_method :original_actions, :actions
    
    def actions
      if payment_method.is_a?(Spree::Gateway::MoipBase) && moip_transaction.present?
        moip_transaction.actions
      else
        original_actions
      end
    end
  end
end
