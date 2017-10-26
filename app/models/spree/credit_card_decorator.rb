require 'validates_cpf_cnpj'

module Spree
  CreditCard.class_eval do
    before_save :set_first_digits

    with_options if: :moip_payment?, on: :create do
      validates :tax_document,
                :birth_date,
                presence: true
      validates :tax_document, cpf: true
    end

    private

    def set_first_digits
      num = number.to_s.gsub(/\s/, '')
      self.first_digits ||= num.length <= 6 ? number : num.slice(0..6)
    end

    def moip_payment?
      payment_method.is_a? Spree::Gateway::MoipCredit
    end
  end
end
