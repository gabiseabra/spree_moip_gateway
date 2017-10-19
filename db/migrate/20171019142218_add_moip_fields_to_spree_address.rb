class AddMoipFieldsToSpreeAddress < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_addresses, :street_number, :integer
    add_column :spree_addresses, :complement, :integer
    add_column :spree_addresses, :district, :string
    add_column :spree_addresses, :tax_document_type, :integer
    add_column :spree_addresses, :tax_document, :string
  end
end
