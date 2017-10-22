class RemoveTaxDocumentTypeFromSpreeCreditCard < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_credit_cards, :tax_document_type, :integer
  end
end
