class CreateSpreeMoipTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_moip_transactions, primary: :transaction_id do |t|
      t.integer :payment_id
      t.string :transaction_id
      t.string :state
      t.integer :total
      t.integer :installments
      t.datetime :changed_at

      t.timestamps
    end
  end
end
