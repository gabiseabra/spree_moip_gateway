class Spree::MoipOrder < Spree::Base
  validates :token,
            :status,
            :total,
            :customer_id,
            presence: true
end
