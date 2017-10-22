class CreateSpreeMoipNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_moip_notifications do |t|
      t.integer :payment_method_id
      t.string :payment_method_type
      t.string :moip_id
      t.string :token

      t.timestamps
    end
    add_index :spree_moip_notifications, %i[payment_method_type payment_method_id],
              name: 'index_spree_moip_notifications_on_payment_method'
  end
end
