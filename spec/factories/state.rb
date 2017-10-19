FactoryGirl.modify do
  factory :state do
    name 'São Paulo'
    abbr 'SP'
    country { |c| Spree::Country.last || c.association(:country) }
  end
end
