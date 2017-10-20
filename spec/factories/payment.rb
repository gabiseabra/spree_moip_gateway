FactoryGirl.modify do
  factory :payment do
    source { association(:credit_card, payment_method: payment_method) }
  end
end
