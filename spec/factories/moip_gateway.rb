FactoryGirl.define do
  factory :moip_base, class: Spree::Gateway::MoipBase do
    name 'Moip Gateway'

    transient do
      token Rails.application.secrets.moip_token || ENV['MOIP_TOKEN']
      key   Rails.application.secrets.moip_key   || ENV['MOIP_KEY']
    end

    before(:create) do |gateway, s|
      %w[token key].each do |preference|
        gateway.send "preferred_#{preference}=", s.send(preference)
      end
    end
  end

  factory :moip_credit, parent: :moip_base, class: Spree::Gateway::MoipCredit

  factory :moip_billet, parent: :moip_base, class: Spree::Gateway::MoipBillet do
    preferred_instruction_1 'test'
    preferred_instruction_2 'test'
    preferred_instruction_3 'test'

    transient { valid_days 3 }

    before(:create) { |gateway, s| gateway.preferred_valid_days = s.valid_days }
  end
end
