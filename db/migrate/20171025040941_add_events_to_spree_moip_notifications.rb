class AddEventsToSpreeMoipNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_moip_notifications, :events, :text
  end
end
