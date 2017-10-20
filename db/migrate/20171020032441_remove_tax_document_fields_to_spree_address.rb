class RemoveTaxDocumentFieldsToSpreeAddress < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_addresses, :tax_document_type, :integer
    remove_column :spree_addresses, :tax_document, :string
  end
end
