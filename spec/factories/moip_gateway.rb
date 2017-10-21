FactoryGirl.define do
  factory :moip_gateway, class: Spree::Gateway::MoipCredit do
    name 'Moip Credit Card Gateway'

    transient do
      token Rails.application.secrets.moip_token || ENV['MOIP_TOKEN']
      key   Rails.application.secrets.moip_key   || ENV['MOIP_KEY']
    end

    before(:create) do |gateway, attr|
      %w[token key].each do |preference|
        gateway.send "preferred_#{preference}=", attr.send(preference)
      end
    end
  end
end
