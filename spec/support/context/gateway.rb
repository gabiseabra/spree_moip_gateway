shared_context 'moip', :moip do
  let(:gateway_type) { |ex| ex.metadata[:moip].is_a?(Symbol) ? ex.metadata[:moip] : :moip_credit }
  let(:gateway) { create("#{gateway_type}_gateway".to_sym) }
  let(:payment) do
    options = { payment_method: gateway, order: order }
    case gateway_type
    when :moip_credit then build(:payment, **options)
    when :moip_billet then build(
      :payment,
      source: Spree::MoipBillet.new(payment_method: gateway),
      **options
    )
    end
  end
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

shared_examples 'moip gateway' do
  before { SpreeMoipGateway.defaults! }
  after(:each) { SpreeMoipGateway.defaults! }

  context 'with webhooks turned on' do
    before(:each) { SpreeMoipGateway.register_webhooks = true }

    it 'registers webhooks upon creation' do
      expect(gateway.moip_notifications).to exist
    end

    it 'unregisters webhooks upon destruction' do
      gateway.destroy!
      expect(gateway.moip_notifications).not_to exist
    end
  end

  context 'with webhooks turned off' do
    before(:each) { SpreeMoipGateway.register_webhooks = false }

    it 'doesn\'t register webhooks upon creation' do
      expect(gateway.moip_notifications).not_to exist
    end
  end
end

shared_examples 'moip authorize' do |state|
  it { expect(response).to be_success }

  it "creates a MoipTransaction with state #{state}" do
    transaction = payment.reload.moip_transaction
    expect(transaction).to be_present
    expect(transaction.payment.id).to eq payment.id
    expect(transaction.payment_method.id).to eq gateway.id
    expect(transaction.state).to eq state
  end
end
