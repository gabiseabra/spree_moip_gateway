class CreateSpreeMoipBillets < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_moip_billets do |t|
      t.integer :payment_method_id
      t.string :url
      t.date :expires_at

      t.timestamps
    end
  end
end
