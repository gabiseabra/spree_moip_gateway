class AddMoipBrandToSpreeCreditCards < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_credit_cards, :moip_brand, :string
  end
end
