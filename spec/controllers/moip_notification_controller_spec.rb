describe Spree::MoipNotificationController, :moip, :with_order do
  let(:authorization) { gateway.api.notifications.show(notification.moip_id).token }
  let(:notification) { gateway.reload.moip_notifications.last }
  let(:token) { notification.token }
  before(:each) do
    VCR.use_cassette('moip_notification_controller') do
      gateway.register_webhooks(true)
      request.headers['Authorization'] = authorization
      complete_order!
    end
  end

  def build_body(replace)
    body = file_fixture('payment.json').read
    replace.each { |key, value| body.gsub! key, value }
    body
  end

  describe 'POST update' do
    let(:body) { '' }
    before(:each) do
      post :update, body: body, format: :json, params: { token: token }
    end

    context 'with invalid authorization' do
      let!(:authorization) { 'test' }
      it { expect(response.status).to eq 401 }
    end

    context 'with invalid resource' do
      let!(:token) { 'test' }
      it { expect(response.status).to eq 404 }
    end

    %w[PRE_AUTHORIZED AUTHORIZED CANCELLED REVERSED SETTLED].each do |state|
      describe "PAYMENT.#{state}" do
        let!(:body) do
          build_body(
            '{TRANSACTION_ID}' => transaction_id,
            '{STATE}' => state,
            '{NOW}' => DateTime.now.to_s(:moip)
          )
        end

        it { expect(response.status).to eq 202 }

        it "updates the moip transaction state to #{state}" do
          expect(payment.moip_transaction.reload.state).to eq state
        end

        it "updates the payment state to #{Spree::MoipTransaction.to_spree_state(state)}" do
          expect(payment.reload.state).to eq Spree::MoipTransaction.to_spree_state(state)
        end
      end
    end
  end
end
