require 'spec_helper'

feature 'Moip credit card checkout', moip: { type: :credit, guest: false } do
  before(:each) do
    allow(order).to receive_messages(available_payment_methods: [gateway])
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: order.user)
  end

  def fill_in_credit_card
    fill_in 'Name on card', with: 'Jane Doe'
    fill_in 'Cpf', with: '678.224.121-83'
    fill_in 'Birth Date', with: '01/01/1990'
    fill_in 'Expiration', with: '05/18'
    fill_in 'Card Number', with: '4012001037141112'
    fill_in 'Card Code', with: '123'
  end

  scenario 'Create payment profile', vcr: { cassette_name: 'features/moip_credit/profile' } do
    SpreeMoipGateway.register_profiles = true

    visit spree.checkout_state_path(:payment)
    fill_in_credit_card
    expect { click_on 'Save and Continue' }.to change { Spree::MoipProfile.count }.by(1)

    expect(current_path).to eq spree.checkout_state_path(:confirm)

    expect { click_on 'Place Order' }.to change { Spree::MoipTransaction.count }.by(1)
  end
end