require 'validates_cpf_cnpj'

module Spree
  User.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    validates :tax_document_type,
              :tax_document,
              presence: true
    validates :tax_document,
              cpf_or_cnpj: true
  end
end
