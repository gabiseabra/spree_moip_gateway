module MoipFeatureHelper
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
end