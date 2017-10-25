class AddTokenToSpreeMoipNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_moip_notifications, :token, :string
    add_index :spree_moip_notifications, :token, unique: true
  end
end
