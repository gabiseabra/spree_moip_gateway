require 'spec_helper'

feature 'Moip credit card checkout', moip: { type: :credit, guest: false }, vcr: { cassette_name: 'features/moip_credit' } do
  before(:each) { stub_controller_for order }

  def stub_controller_for(current_order)
    allow(current_order).to receive_messages(available_payment_methods: [gateway])
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: current_order)
    allow_any_instance_of(Spree::StoreController).to receive_messages(try_spree_current_user: current_order.user)
  end

  def create_payment_profile!
    gateway.create_profile payment
    stub_controller_for order.reload
  end

  def fill_in_credit_card
    fill_in 'Name on card', with: 'Jane Doe'
    fill_in 'Cpf', with: '678.224.121-83'
    fill_in 'Birth Date', with: '01/01/1990'
    fill_in 'Expiration', with: '05/18'
    fill_in 'Card Number', with: '4012001037141112'
    fill_in 'Card Code', with: '123'
  end

  xscenario 'Regular checkout' do
    visit spree.checkout_state_path(:payment)
    fill_in_credit_card
    expect { click_on 'Save and Continue' }.to change { Spree::MoipTransaction.count }.by(1)

    expect(current_path).to eq spree.order_path(Spree::Order.last)
  end

  context 'with payment profiles enabled' do
    before(:each) { SpreeMoipGateway.register_profiles = true }

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
end