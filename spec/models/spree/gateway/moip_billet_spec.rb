require 'spec_helper'

describe Spree::Gateway::MoipBillet,
         moip: :moip_billet,
         with_order: { guest: true },
         vcr: { cassette_name: 'moip_billet' } do
  it_behaves_like 'moip gateway'

  describe '#authorize', vcr: { cassette_name: 'moip_billet/authorize' } do
    let(:response) { gateway.authorize total_cents, source, gateway_options }
    before(:each) do
      add_payment_to_order!
      response
    end

    it_behaves_like 'moip authorize', 'WAITING'
  end
end
