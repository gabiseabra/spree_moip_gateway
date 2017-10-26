class Spree::MoipBillet < ApplicationRecord
  belongs_to :payment_method
  has_one :payment, foreign_key: :source_id, as: :source, class_name: 'Spree::Payment'
  has_one :order, through: :payment

  def method_type
    '_check.html.erb'
  end
end
