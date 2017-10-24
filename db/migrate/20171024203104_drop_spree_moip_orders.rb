class DropSpreeMoipOrders < ActiveRecord::Migration[5.1]
  def change
    drop_table :spree_moip_orders
  end
end
