class Spree::MoipBillet < Spree::Base
  belongs_to :payment_method
  belongs_to :user
  has_one :payment, foreign_key: :source_id, as: :source, class_name: 'Spree::Payment'
  has_one :order, through: :payment
end
