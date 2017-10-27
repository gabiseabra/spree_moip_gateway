require 'spec_helper'

describe Spree::Gateway::MoipBillet, moip: { type: :billet }, vcr: { cassette_name: 'moip_billet' } do
  it_behaves_like 'moip gateway'

  describe '#authorize', vcr: { cassette_name: 'moip_billet/authorize' } do
    let(:response) { gateway.authorize 1000, payment_source, gateway_options }
    before(:each) do
      add_payment_to_order!
      response
    end

    it_behaves_like 'moip authorize', 'WAITING'

    it 'saves billet data to payment source' do
      expect(payment_source.url).to be_present
      expect(payment_source.expires_at).to be_present
    end
  end
end
