require 'spec_helper'

describe Spree::Gateway::MoipCredit, moip: { type: :credit }, vcr: { cassette_name: 'models/moip_credit' } do
  it_behaves_like 'moip gateway'

  describe '#create_profile', vcr: { cassette_name: 'models/moip_credit/create_profile' } do
    let(:profile) { order.user.moip_profiles.where(payment_method: gateway).last }
    before(:each) { SpreeMoipGateway.register_profiles = true }
    before(:each) { gateway.create_profile payment }

    context 'with a registered account', moip: { guest: false } do
      it 'creates a MoipProfile with a payment source' do
        expect(profile).to be_present
        expect(profile.credit_cards).to exist
        expect(profile.credit_cards.count).to eq 1
      end

      it 'saves moip data to payment source' do
        expect(payment_source.gateway_customer_profile_id).to be_present
        expect(payment_source.gateway_payment_profile_id).to be_present
        expect(payment_source.moip_brand).to be_present
      end
    end

    context 'with an existing moip profile', moip: { guest: false }, vcr: { cassette_name: 'models/moip_credit/create_other_profile' } do
      let(:other_source) { build(:credit_card, number: '5555666677778884', verification_value: '123') }
      let(:other_payment) { build(:payment, payment_method: gateway, source: other_source, order: order) }
      before(:each) { gateway.create_profile other_payment }

      it 'adds a new payment source to the existing moip profile' do
        expect(profile.credit_cards.count).to eq 2
      end
    end

    context 'without a registered account' do
      it 'doesn\'t update the payment source' do
        expect(payment_source.gateway_customer_profile_id).not_to be_present
        expect(payment_source.gateway_payment_profile_id).not_to be_present
      end
    end
  end

  describe '#purchase', vcr: { cassette_name: 'models/moip_credit/purchase' } do
    let(:response) { gateway.purchase 1000, payment_source, gateway_options }
    before(:each) { add_payment_to_order! }

    it_behaves_like 'moip authorize', 'IN_ANALYSIS'

    it 'doesn\'t log sensitive data' do
      expect(response.to_yaml).not_to include payment_source.number
    end

    context 'with an invalid credit card number', vcr: { cassette_name: 'models/moip_credit/purchase/invalid' } do
      before(:each) { payment_source.number = 'TEST_NUMBER' }

      it 'responds with an error message' do
        expect(response).not_to be_success
        expect(response.message).to be_present
      end
    end

    context 'with payment profile', moip: { guest: false }, vcr: { cassette_name: 'models/moip_credit/purchase/profile' } do
      before(:each) { SpreeMoipGateway.register_profiles = true }
      it { expect(response).to be_success }
    end

    xcontext 'with encryptped data', vcr: { cassette_name: 'models/moip_credit/purchase/encrypted' } do
      before { payment_source.encrypted_data = 'test' }
      it { expect(response).to be_success }
    end
  end

  describe '#void', vcr: { cassette_name: 'models/moip_credit/void' } do
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

  describe '#capture', vcr: { cassette_name: 'models/moip_credit/capture' } do
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
