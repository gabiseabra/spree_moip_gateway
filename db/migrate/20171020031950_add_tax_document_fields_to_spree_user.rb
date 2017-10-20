class AddTaxDocumentFieldsToSpreeUser < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :tax_document_type, :integer
    add_column :spree_users, :tax_document, :string
  end
end
