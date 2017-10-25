class Spree::MoipNotification < Spree::Base
  belongs_to :payment_method, polymorphic: true
  before_destroy :unregister_webhook

  private

  def unregister_webhook
    payment_method.provider.api.notifications.delete moip_id
  end
end
