SpreeMoipGateway.config do |config|
  # Register webhooks for new moip payment methods to keep track of transactions.
  # Spree's router must be configured with a host name to register webhooks.
  # When this is set to false, the "spree_moip_gateway:update_transactions" rake
  # task should be used with a cron tab instead, to query Moip's api regularly
  # for updates.
  # config.register_webhooks = false

  # Register payment profiles for one click buy
  # config.register_profiles = false
end
