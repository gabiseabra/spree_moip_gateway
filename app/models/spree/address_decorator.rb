require 'validates_cpf_cnpj'

module Spree
  Address.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    validates :street_number,
              :district,
              :tax_document_type,
              :tax_document,
              presence: true
    validates :zipcode, format: { :with => /\A(\d){5}-(\d){3}\z/ }
    validates :phone, format: { :with => /\A(\+(\d){2})?\((\d){2}\)(\d){4,5}-(\d){4,5}\z/ }
    validates :tax_document, cpf_or_cnpj: true
  end
end
