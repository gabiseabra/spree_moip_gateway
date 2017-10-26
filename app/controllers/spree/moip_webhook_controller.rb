module Spree
  class MoipWebhookController < Spree::BaseController
    skip_before_filter :verify_authenticity_token
    before_filter :authenticate

    def update
    end

    private

    def notification
      @notification ||= Spree::MoipNotification.find_by(token: params[:token])
      raise ActiveRecord::RecordNotFound unless @notification.present?
    end

    def authenticate
      unless notification.authenticate(request.headers['Authorization'])
        render nothing: true, status: :unauthorized
      end
    end
  end
end
