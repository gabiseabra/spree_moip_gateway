FactoryGirl.modify do
  factory :order do
    email 'spree@example.com'
    tax_document_type :cpf
    tax_document '678.224.121-83'

    trait :as_guest do
      user nil
      guest_token 'test'
    end

    trait :populated do
      before(:create) do |order|
        create(:line_item, order: order)
      end
    end

    # address -> delivery
    trait :at_delivery do
      association :bill_address, factory: :address
      association :ship_address, factory: :address

      before(:create) do
        # Create eligible shipping method if none exists
        create(:global_zone) unless Spree::Zone.global
        create(:shipping_method) unless Spree::ShippingMethod.exists?
      end

      after(:create) { |order| order.next! while order.state != 'delivery' }
    end

    # delivery -> payment
    trait :at_payment do
      at_delivery

      after(:create) { |order| order.next! while order.state != 'payment' }
    end
  end
end
