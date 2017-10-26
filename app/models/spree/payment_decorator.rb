module Spree
  Payment.class_eval do
    has_one :moip_transaction

    def actions
      if payment_method.is_a?(Spree::Gateway::MoipBase) && moip_transaction.present?
        moip_transaction.actions
      else
        super
      end
    end
  end
end
