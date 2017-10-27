FactoryGirl.modify do
  factory :payment do
    source { association(:credit_card, payment_method: payment_method) }

    after(:build) do |payment|
      payment.source.user = payment.order.user
    end
  end
end
