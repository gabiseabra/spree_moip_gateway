class RenameTokenInSpreeMoipNotificationsToMoipToken < ActiveRecord::Migration[5.1]
  def change
    rename_column :spree_moip_notifications, :token, :moip_token
  end
end
