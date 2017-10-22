module Spree
  class MoipWebhookController < Spree::BaseController
    skip_before_filter :verify_authenticity_token

    # ssl_required

    def update
    end
  end
end
