shared_context 'order' do
  let(:order) { create(:order, :populated, :at_payment) }
end

shared_context 'guest_order' do
  let(:order) { create(:order, :populated, :at_payment, :as_guest) }
end
