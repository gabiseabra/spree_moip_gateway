Spree::CheckoutController.class_eval do
  around_action :process_verification_value, only: :update

  private

  def moip_payments
    @order.unprocessed_payments.select do |payment|
      payment.payment_method.is_a? Spree::Gateway::MoipCredit
    end
  end

  def process_verification_value
    restore_verification_value if params[:state] == 'confirm'
    yield
    persist_verification_value if params[:state] == 'payment'
    session.delete(:moip_checkout_cvc) if @order.complete?
  end

  def restore_verification_value
    return unless session[:moip_checkout_cvc].present?
    moip_payments.each do |payment|
      payment.source.verification_value = session[:moip_checkout_cvc][payment.id.to_s]
    end
  end

  def persist_verification_value
    session[:moip_checkout_cvc] = {}
    moip_payments.each do |payment|
      session[:moip_checkout_cvc][payment.id.to_s] = payment.source.verification_value
    end
  end
end
