require 'spec_helper'

describe Spree::Gateway::MoipCredit, cassette: 'moip_credit' do
  include_context 'guest_order'
  include_context 'payment'

  let(:gateway) { create(:moip_gateway) }

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

  describe '#create_profile', cassette: 'moip_credit/create_profile' do
    let(:profile) { order.user.moip_profiles.where(payment_method: gateway).last }
    before(:each) { gateway.create_profile payment }

    context 'with a registered account' do
      include_context 'order'

      it 'creates a MoipProfile with a payment source' do
        expect(profile).to be_present
        expect(profile.credit_cards).to exist
        expect(profile.credit_cards.count).to eq 1
      end

      it 'updates the payment source' do
        expect(source.gateway_customer_profile_id).to be_present
        expect(source.gateway_payment_profile_id).to be_present
      end
    end

    context 'with an existing moip profile', cassette: 'moip_credit/create_other_profile' do
      include_context 'order'

      let(:other_source) { build(:credit_card, number: '5555666677778884', verification_value: '123') }
      let(:other_payment) { build(:payment, payment_method: gateway, source: other_source, order: order) }
      before(:each) { gateway.create_profile other_payment }

      it 'adds a new payment source to the existing moip profile' do
        expect(profile.credit_cards.count).to eq 2
      end
    end

    context 'without a registered account' do
      it 'doesn\'t update the payment source' do
        expect(source.gateway_customer_profile_id).not_to be_present
        expect(source.gateway_payment_profile_id).not_to be_present
      end
    end
  end

  describe '#purchase', cassette: 'moip_credit/purchase' do
    let(:purchase!) { gateway.purchase total_cents, source, gateway_options }
    let(:transaction_id) { purchase!.authorization }
    before(:each) do
      puts order.user
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
  end

  describe '#void', cassette: 'moip_credit/void' do
    let(:void!) { payment.reload.void! }
    before(:each) do
      complete_order!
      authorize_payment!
      void!
    end

    it 'updates the payment state to "void"' do
      expect(payment.reload.state).to eq 'void'
    end
  end

  describe '#capture', cassette: 'moip_credit/capture' do
    let(:capture!) { payment.reload.capture! }
    before(:each) do
      Spree::Config[:auto_capture] = false
      complete_order!
      authorize_payment!
      capture!
    end

    it 'updates the payment state to "completed"' do
      expect(payment.reload.state).to eq 'completed'
    end
  end
end
