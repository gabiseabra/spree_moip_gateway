shared_context 'with_payment', :with_payment do
  let(:payment) { build(:payment, payment_method: gateway, order: order) }
  let(:gateway_options) { Spree::Payment::GatewayOptions.new(payment).to_hash }
  let(:total) { payment.amount }
  let(:total_cents) { Spree::Money.new(payment.amount).cents }
  let(:source) { payment.payment_source }
  let(:transaction_id) { payment.reload.transaction_id }
  let(:add_payment_to_order!) { order.payments << payment }
  let(:authorize_payment!) do
    path = "/simulador/authorize?payment_id=#{transaction_id}&amount=#{total_cents}"
    gateway.provider.client.get(path)
  end
  let(:complete_order!) do
    add_payment_to_order!
    until order.completed? do order.next! end
  end
end
