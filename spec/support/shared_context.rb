shared_context 'moip', :moip do
  let(:moip_options) do |ex|
    options = ex.metadata[:moip].is_a?(Hash) ? ex.metadata[:moip] : {}
    options.reverse_merge(
      type: :credit,
      guest: true
    )
  end
  let(:gateway) { create("moip_#{moip_options[:type]}_gateway".to_sym) }
  let!(:order) do
    traits = %i[populated at_payment]
    traits << :as_guest if moip_options[:guest]
    create(:order, *traits)
  end
  let(:payment) do
    options = { payment_method: gateway, order: order }
    case moip_options[:type]
    when :credit then build(:payment, **options)
    when :billet then build(:payment, source: create(:moip_billet_source), **options)
    end
  end
  let(:gateway_options) { Spree::Payment::GatewayOptions.new(payment).to_hash }
  let(:payment_source) { payment.payment_source }
  let(:transaction_id) { payment.reload.transaction_id }
  let(:add_payment_to_order!) { order.payments << payment }
  let(:authorize_payment!) do
    cents = (payment.amount * 100).to_i
    path = "/simulador/authorize?payment_id=#{transaction_id}&amount=#{cents}"
    gateway.provider.client.get(path)
  end
  let(:complete_order!) do
    add_payment_to_order!
    until order.completed? do order.next! end
  end

  before { SpreeMoipGateway.defaults! }
  after(:each) { SpreeMoipGateway.defaults! }
end

shared_examples 'moip gateway' do
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
    response
    transaction = payment.reload.moip_transaction
    expect(transaction).to be_present
    expect(transaction.payment.id).to eq payment.id
    expect(transaction.payment_method.id).to eq gateway.id
    expect(transaction.state).to eq state
  end
end
