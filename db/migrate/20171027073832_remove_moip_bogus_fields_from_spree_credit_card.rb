class RemoveMoipBogusFieldsFromSpreeCreditCard < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_credit_cards, :first_digits, :string
  end
end
