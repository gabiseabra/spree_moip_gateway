class Spree::MoipTransaction < Spree::Base
  belongs_to :payment
  has_one :order, through: :payment
  has_one :payment_method, through: :payment
end
