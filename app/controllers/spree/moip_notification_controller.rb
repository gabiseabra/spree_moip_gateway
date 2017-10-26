module Spree
  class MoipNotificationController < Spree::BaseController
    skip_before_action :verify_authenticity_token
    before_action :load_resource
    before_action :authenticate

    def update
      body = JSON.parse request.body.read
      body.deep_transform_keys! { |key| key.to_s.underscore }
      data = RecursiveOpenStruct.new body, recurse_over_arrays: true
      payment_data = data.resource.payment
      transaction = Spree::MoipTransaction.find_by(transaction_id: payment_data.id)
      if transaction.present? && transaction.payment_method.id == @notification.payment_method.id
        transaction.process_update payment_data
      end
      head 202, content_type: 'text/html'
    end

    private

    def load_resource
      @notification ||= Spree::MoipNotification.find_by(token: params[:token])
      head 404, content_type: 'text/html' unless @notification.present?
    end

    def authenticate
      unless @notification.authenticate(request.headers['Authorization'])
        head 401, content_type: 'text/html'
      end
    end
  end
end
