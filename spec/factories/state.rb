FactoryGirl.modify do
  factory :state do
    name 'São Paulo'
    abbr 'SP'
    country do |country|
      if br = Spree::Country.find_by(iso: 'BR')
        country = br
      else
        country.association(:country)
      end
    end
  end
end
