module Spree
  Address.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    validates :street_number,
              :district,
              :tax_document_type,
              :tax_document,
              presence: true
    validates :zipcode, format: { :with => /^(\d){5}-(\d){3}$/ }
    validates :phone, format: { :with => /^(\+(\d){2})?\((\d){2}\)(\d){4,5}-(\d){4,5}$/ }
    validates :tax_document, cpf_or_cnpj: true
  end
end
