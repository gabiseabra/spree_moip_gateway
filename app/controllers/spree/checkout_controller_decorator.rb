Spree::CheckoutController.class_eval do
  around_action :process_verification_value, only: :update

  private

  def moip_payments
    @order.unprocessed_payments.select do |payment|
      payment.payment_method.is_a? Spree::Gateway::MoipCredit
    end
  end

  # Persist verification value for new payment profiles between
  # profile creation (payment) and payment processing (confirm)
  def process_verification_value
    yield and return unless SpreeMoipGateway.register_profiles
    restore_verification_value if params[:state] == 'confirm'
    yield
    persist_verification_value if params[:state] == 'payment'
    session.delete(:moip_checkout) if @order.complete?
  end

  def restore_verification_value
    return unless session[:moip_checkout].present?
    moip_payments.each do |payment|
      data = session[:moip_checkout][payment.id.to_s]
      payment.source.verification_value = data['cvc']
      payment.source.number = data['number']
    end
  end

  def persist_verification_value
    session[:moip_checkout] = {}
    cvc_confirm = params[:order].try(:[], :cvc_confirm)
    moip_payments.each do |payment|
      session[:moip_checkout][payment.id.to_s] = {
        'number' => payment.source.number,
        'cvc' => payment.source.verification_value || cvc_confirm
      }
    end
  end
end
