require 'validates_cpf_cnpj'

module Spree
  CreditCard.class_eval do
    with_options if: :moip_payment?, on: :create do
      validates :tax_document,
                :birth_date,
                presence: true
      validates :tax_document, cpf: true
    end

    %w[capture void].each do |action|
      alias_method :"original_can_#{action}?", :"can_#{action}?"

      define_method :"can_#{action}?" do |payment|
        if moip_payment?
          payment.moip_transaction.send "can_#{action}?"
        else
          send "original_can_#{action}?", payment
        end
      end
    end

    private

    def moip_payment?
      payment_method.is_a? Spree::Gateway::MoipCredit
    end
  end
end
