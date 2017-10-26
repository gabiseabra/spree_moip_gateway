class RenameMoipTokenInSpreeMoipNotifications < ActiveRecord::Migration[5.1]
  def change
    rename_column :spree_moip_notifications, :moip_token, :password_digest
  end
end
