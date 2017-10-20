require 'validates_cpf_cnpj'

module Spree
  Address.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    validates :street_number,
              :district,
              :tax_document_type,
              :tax_document,
              presence: true
    validates :phone,
              presence: true,
              format: { with: /\A(\+(\d){2})?\((\d){2}\)(\d){4,5}-(\d){4,5}\z/ }
    validates :tax_document,
              cpf_or_cnpj: true

    def moip_hash
      {
        full_name: full_name,
        street: address1,
        street_number: street_number,
        complement: complement,
        district: district,
        city: city,
        zip_code: zipcode,
        state: state_text,
        country: country.try(:iso3),
        phone: phone,
        tax_document_type: tax_document_type.to_s.upcase,
        tax_document: tax_document
      }
    end
  end
end
