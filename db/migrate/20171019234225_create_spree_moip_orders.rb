class CreateSpreeMoipOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_moip_orders, primary: :token do |t|
      t.string :order
      t.string :token
      t.string :status
      t.integer :total

      t.timestamps
    end
    add_index :spree_moip_orders, :order
  end
end
