class Spree::MoipNotification < Spree::Base
  belongs_to :payment_method, polymorphic: true
end
