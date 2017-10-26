class AddFirstDigitsToSpreeCreditCards < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_credit_cards, :first_digits, :string
  end
end
