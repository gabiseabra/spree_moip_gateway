FactoryGirl.define do
  factory :moip_billet_source, class: Spree::MoipBillet do
    association(:payment_method, factory: :check_payment_method)
  end
end
