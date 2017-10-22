require 'validates_cpf_cnpj'

module Spree
  Order.class_eval do
    enum tax_document_type: %i[cpf cnpj]

    before_create :set_default_tax_document

    validates :tax_document_type,
              :tax_document,
              presence: true
    validates :tax_document,
              cpf_or_cnpj: true

    private

    def set_default_tax_document
      if user.present?
        self.tax_document_type ||= user.tax_document_type
        self.tax_document      ||= user.tax_document
      end
    end
  end
end
