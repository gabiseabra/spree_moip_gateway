require 'validates_cpf_cnpj'

module Spree
  User.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    validates :tax_document,
              cpf_or_cnpj: true,
              allow_blank: true
  end
end
