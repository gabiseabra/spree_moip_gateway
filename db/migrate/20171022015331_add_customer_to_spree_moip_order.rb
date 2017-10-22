class AddCustomerToSpreeMoipOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_moip_orders, :customer_id, :string
  end
end
