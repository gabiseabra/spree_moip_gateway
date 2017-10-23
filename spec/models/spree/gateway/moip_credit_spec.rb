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
    url = "/simulador/authorize?payment_id=#{transaction_id}&amount=#{total_cents}"
    gateway.provider.client.get(url)
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
    let(:response) { gateway.purchase total_cents, source, gateway_options }
    before(:each) { VCR.insert_cassette 'moip_credit/purchase', record: :new_episodes }
    after(:each) { VCR.eject_cassette }
    before(:each) { add_payment_to_order! }

    it 'succeeds' do
      expect(response.success?).to be true
    end

    it 'saves gateway data to credit card' do
      response
      expect(source.gateway_customer_profile_id).to be_present
      expect(source.gateway_payment_profile_id).to be_present
    end
  end

  xdescribe '#void' do
    let(:void!) { gateway.void transaction_id, gateway_options }
    before(:each) { VCR.insert_cassette 'moip_credit/void', record: :new_episodes }
    after(:each) { VCR.eject_cassette }
    before(:each) do
      complete_order!
      authorize_payment!
      void!
    end

    it 'updates the payment state to "void"' do
      expect(payment.reload.state).to be 'void'
    end
  end

  xdescribe '#capture' do
    before(:each) { VCR.insert_cassette 'moip_credit/capture', record: :new_episodes }
    after(:each) { VCR.eject_cassette }
    before(:each) do
      Spree::Config[:auto_capture] = false
      complete_order!
      authorize_payment!
    end

    it 'updates the payment state to "completed"' do
      expect(payment).to be_pending
      payment.reload.capture!
      expect(payment).to be_completed
    end
  end
end
