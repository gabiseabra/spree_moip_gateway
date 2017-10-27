class AddUserIdToSpreeMoipBillets < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_moip_billets, :user_id, :integer
  end
end
