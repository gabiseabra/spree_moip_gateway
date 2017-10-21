require 'spec_helper'

describe Spree::Gateway::MoipCredit do
  let(:order) { create(:order, :populated, :at_payment) }
  let(:gateway) { create(:moip_gateway) }
  let(:payment) { build(:payment, payment_method: gateway, order: order) }
  let(:total_cents) { Spree::Money.new(payment.amount).cents }
  let(:source) { payment.payment_source }
  let(:add_payment_to_order!) { order.payments << payment }

  describe '#purchase' do
    let(:gateway_options) { Spree::Payment::GatewayOptions.new(payment) }
    let(:response) { gateway.purchase total_cents, source, gateway_options }
    before { add_payment_to_order! }
    before { VCR.insert_cassette 'moip_credit_card/payment' }
    after { VCR.eject_cassette }

    it 'succeeds' do
      expect(response.success?).to be true
    end
  end
end
