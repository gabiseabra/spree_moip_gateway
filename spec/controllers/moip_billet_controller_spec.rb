describe Spree::MoipBilletController, :with_order, moip: :moip_billet do
  let(:user) { order.user }
  before(:each) do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages spree_current_user: user
    allow(controller).to receive_messages current_order: order
    VCR.use_cassette('moip_billet_controller') { complete_order! }
  end

  describe 'GET show' do
    let(:request!) { get :show, params: { payment: payment.number } }
    before(:each) do
      stub_request(:get, source.url).to_return(status: 200, body: '<div>BOLETO</div>')
      VCR.turned_off { request! }
    end

    context 'with invalid authorization' do
      let(:user) { create(:user) }
      it { expect(response).to redirect_to spree.forbidden_path }
    end

    context 'with invalid resource' do
      let!(:request!) { get :show, params: { payment: 'test' } }
      it { expect(response.status).to eq 404 }
    end

    it do
      expect(response.status).to eq 200
      expect(response.content_type).to eq 'text/html'
      expect(response.body).to eq '<div>BOLETO</div>'
    end
  end
end
