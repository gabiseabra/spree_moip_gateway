shared_context 'with_order', :with_order do
  let!(:order) do |ex|
    options = ex.metadata[:with_order].is_a?(Hash) ? ex.metadata[:with_order] : {}
    traits = [:populated, :at_payment]
    traits << :as_guest if options[:guest]
    create(:order, *traits)
  end
end
