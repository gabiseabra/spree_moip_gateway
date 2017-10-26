require 'validates_cpf_cnpj'

module Spree
  User.class_eval do
    has_many :moip_profiles

    enum tax_document_type: %i[cpf cnpj]

    validates :tax_document,
              cpf_or_cnpj: true,
              allow_blank: true

    def moip_profile_ready?
      tax_document.present? && shipping_address.present?
    end

    def moip_gateway_profile(gateway)
      moip_profiles.where(payment_method: gateway).last || Spree::MoipProfile.create(
        user: self,
        payment_method: gateway
      )
    end
  end
end
