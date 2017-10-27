require 'spec_helper'

feature 'Moip boleto checkout', moip: { type: :billet, guest: false }, vcr: { cassette_name: 'features/moip_billet' } do
  include MoipFeatureHelper

  before(:each) { stub_controller_for order }

  scenario 'Regular checkout' do
    visit spree.checkout_state_path(:payment)
    expect {
      click_on 'Save and Continue'
    }.to change { Spree::MoipBillet.count }.by(1)
     .and change { Spree::MoipTransaction.count }.by(1)

    expect(current_path).to eq spree.order_path(Spree::Order.last)
    expect(page).to have_selector 'a:contains("Print Billet")'
  end
end
