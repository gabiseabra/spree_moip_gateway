require 'validates_cpf_cnpj'

module Spree
  CreditCard.class_eval do
    const_set :ORIGINAL_CARD_TYPES, CreditCard::CARD_TYPES
    remove_const :CARD_TYPES
    const_set :CARD_TYPES, CreditCard::ORIGINAL_CARD_TYPES.reverse_merge(
      elo: /^((((636368)|(438935)|(504175)|(451416)|(636297))\d{0,10})|((5067)|(4576)|(4011))\d{0,12})$/,
      hipercard: /^(606282\d{10}(\d{3})?)|(3841\d{15})$/
    )

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
