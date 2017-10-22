require 'spec_helper'

describe Spree::Gateway::MoipCredit do
  let(:order) { create(:order, :populated, :at_payment) }
  let(:gateway) { create(:moip_gateway) }
  let(:payment) { build(:payment, payment_method: gateway, order: order) }
  let(:total_cents) { Spree::Money.new(payment.amount).cents }
  let(:source) { payment.payment_source }
  let(:add_payment_to_order!) { order.payments << payment }
  before(:each) { VCR.insert_cassette 'moip_credit', record: :new_episodes }
  after(:each) { VCR.eject_cassette }

  it 'registers webhooks upon creation' do
    expect(gateway.moip_notifications).to exist
  end

  it 'unregisters webhooks upon destruction' do
    gateway.destroy!
    expect(gateway.moip_notifications).not_to exist
  end

  describe '#purchase' do
    let(:gateway_options) { Spree::Payment::GatewayOptions.new(payment) }
    let(:response) { gateway.purchase total_cents, source, gateway_options }
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
end
