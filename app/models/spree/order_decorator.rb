require 'validates_cpf_cnpj'

module Spree
  Order.class_eval do
    attr_accessor :cvc_confirm

    enum tax_document_type: %i[cpf cnpj]

    before_create :set_default_tax_document

    with_options if: :require_tax_document? do
      validates :tax_document_type,
                :tax_document,
                presence: true
      validates :tax_document,
                cpf_or_cnpj: true
    end

    private

    def require_tax_document?
      true unless new_record? || %w[cart address].include?(state)
    end

    def set_default_tax_document
      if user.present?
        self.tax_document_type ||= user.tax_document_type
        self.tax_document      ||= user.tax_document
      end
    end
  end
end
