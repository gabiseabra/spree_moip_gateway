module Spree
  Payment.class_eval do
    has_one :moip_transaction
  end
end
