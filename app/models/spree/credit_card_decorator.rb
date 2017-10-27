require 'validates_cpf_cnpj'

module Spree
  CreditCard.class_eval do
    with_options if: :moip_payment?, on: :create do
      validates :tax_document,
                :birth_date,
                presence: true
      validates :tax_document, cpf: true
    end

    private

    def moip_payment?
      payment_method.is_a? Spree::Gateway::MoipCredit
    end
  end
end
