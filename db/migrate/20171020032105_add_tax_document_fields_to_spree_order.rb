class AddTaxDocumentFieldsToSpreeOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_orders, :tax_document_type, :integer
    add_column :spree_orders, :tax_document, :string
  end
end
