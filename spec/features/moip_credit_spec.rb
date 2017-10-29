require 'spec_helper'

feature 'Moip credit card checkout', moip: { type: :credit }, vcr: { cassette_name: 'features/moip_credit' } do
  include MoipFeatureHelper

  before(:each) { stub_controller_for order }

  scenario 'Complete checkout' do
    visit spree.checkout_state_path(:payment)
    fill_in_credit_card
    expect { click_on 'Save and Continue' }.to change { Spree::MoipTransaction.count }.by(1)

    expect(current_path).to eq spree.order_path(Spree::Order.last)
  end

  context 'with payment profiles enabled' do
    before(:each) { SpreeMoipGateway.register_profiles = true }

    context 'registered user', moip: { guest: false } do
      scenario 'Create new payment profile', vcr: { cassette_name: 'features/moip_credit/new_profile' } do
        visit spree.checkout_state_path(:payment)
        fill_in_credit_card
        expect { click_on 'Save and Continue' }.to change { Spree::MoipProfile.count }

        expect(current_path).to eq spree.checkout_state_path(:confirm)
        expect { click_on 'Place Order' }.to change { Spree::MoipTransaction.count }.by(1)

        expect(current_path).to eq spree.order_path(Spree::Order.last)
      end

      scenario 'Use existing payment profile', vcr: { cassette_name: 'features/moip_credit/profile' } do
        create_payment_profile!

        visit spree.checkout_state_path(:payment)
        fill_in id: 'cvc_confirm', with: '123'
        expect { click_on 'Save and Continue' }.not_to change { Spree::MoipProfile.count }

        expect(current_path).to eq spree.checkout_state_path(:confirm)
        expect { click_on 'Place Order' }.to change { Spree::MoipTransaction.count }.by(1)

        expect(current_path).to eq spree.order_path(Spree::Order.last)
      end
    end

    context 'guest', moip: { guest: true } do
      scenario 'Complete checkout', vcr: { cassette_name: 'features/moip_credit/guest' } do
        visit spree.checkout_state_path(:payment)
        fill_in_credit_card
        expect { click_on 'Save and Continue' }.not_to change { Spree::MoipProfile.count }

        expect(current_path).to eq spree.checkout_state_path(:confirm)
        expect { click_on 'Place Order' }.to change { Spree::MoipTransaction.count }.by(1)

        expect(current_path).to eq spree.order_path(Spree::Order.last)
      end
    end
  end
end
