namespace :spree_moip_gateway do
  desc 'Updates states for MoipTransactions and associated Orders with Payments'
  task update_transactions: :environment do
    puts Spree::MoipTransaction.fetch_updates
  end
end
