require 'validates_cpf_cnpj'

module Spree
  CreditCard.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    with_options if: :moip_payment?, on: :create do
      validates :tax_document_type,
                :tax_document,
                :birth_date,
                presence: true
      validates :tax_document,
                cpf_or_cnpj: true
    end

    private

    def moip_payment?
      payment_method.is_a? Spree::Gateway::MoipCredit
    end
  end
end
