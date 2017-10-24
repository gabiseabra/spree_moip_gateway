require 'spec_helper'

describe Spree::Gateway::MoipCredit do
  let(:order) { create(:order, :populated, :at_payment) }
  let(:gateway) { create(:moip_gateway) }
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

  before(:each) { VCR.insert_cassette 'moip_credit', record: :new_episodes }
  after(:each) { VCR.eject_cassette }

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

  describe '#purchase' do
    let(:purchase!) { gateway.purchase total_cents, source, gateway_options }
    let(:transaction_id) { purchase!.authorization }
    before(:each) { VCR.insert_cassette 'moip_credit/purchase', record: :new_episodes }
    after(:each) { VCR.eject_cassette }
    before(:each) do
      add_payment_to_order!
      purchase!
    end

    it 'creates a MoipTransaction in analysis' do
      transaction = Spree::MoipTransaction.find_by(transaction_id: transaction_id)
      expect(transaction).to be_present
      expect(transaction.payment.id).to eq payment.id
      expect(transaction.payment_method.id).to eq gateway.id
      expect(transaction.state).to eq 'IN_ANALYSIS'
    end

    it 'saves gateway data to credit card' do
      expect(source.gateway_customer_profile_id).to be_present
      expect(source.gateway_payment_profile_id).to be_present
    end
  end

  describe '#void' do
    let(:void!) { payment.reload.void! }
    before(:each) { VCR.insert_cassette 'moip_credit/void', record: :new_episodes }
    after(:each) { VCR.eject_cassette }
    before(:each) do
      complete_order!
      authorize_payment!
      void!
    end

    it 'updates the payment state to "void"' do
      expect(payment.reload.state).to eq 'void'
    end
  end

  xdescribe '#capture' do
    let(:capture!) { payment.reload.capture! }
    before(:each) { VCR.insert_cassette 'moip_credit/capture', record: :new_episodes }
    after(:each) { VCR.eject_cassette }
    before(:each) do
      Spree::Config[:auto_capture] = false
      complete_order!
      authorize_payment!
    end

    it 'updates the payment state to "completed"' do
      expect(payment).to be_pending
      capture!
      expect(payment).to be_completed
    end
  end
end
