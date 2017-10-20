FactoryGirl.modify do
  factory :address do
    address1 'Avenida Faria Lima'
    address2 ''
    street_number 100
    district 'Itaim'
    city 'São Paulo'
    zipcode '01452-001'
    phone '(21)0000-0000'
    state { |s| Spree::State.last || s.association(:state) }
    country { state.country }
  end
end
