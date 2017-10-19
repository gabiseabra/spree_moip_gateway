FactoryGirl.modify do
  factory :state do
    name 'São Paulo'
    abbr 'SP'
    association :country, factory: :country
  end
end
