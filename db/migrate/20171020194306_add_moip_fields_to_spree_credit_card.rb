class AddMoipFieldsToSpreeCreditCard < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_credit_cards, :tax_document_type, :integer
    add_column :spree_credit_cards, :tax_document, :string
    add_column :spree_credit_cards, :birth_date, :date
  end
end
