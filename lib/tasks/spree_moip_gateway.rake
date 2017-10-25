namespace :spree_moip_gateway do
  desc 'Updates states for MoipTransactions and associated Orders with Payments'
  task update_transactions: :environment do
    puts Spree::MoipTransaction.fetch_updates
  end

  task unregister_webhooks: :environment do
    Spree::MoipNotification.all.each do |notification|
      notification.destroy!
    end
  end

  task register_webhooks: :environment do
    types = [Spree::Gateway::MoipCredit.name]
    Spree::PaymentMethod.where(type: types).each do |gateway|
      gateway.register_webhooks(true)
    end
  end
end
