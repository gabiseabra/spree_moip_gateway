module Spree
  class MoipBilletController < Spree::StoreController
    before_action :load_resource
    before_action :authorize

    def show
      expires_in 3.days, public: false
      fresh_when last_modified: @billet.updated_at.utc, etag: @billet
      response = Net::HTTP.get(URI.parse(@billet.url))
      render html: response.html_safe
    end

    private

    def load_resource
      @payment ||= Spree::Payment.find_by(number: params[:payment])
      @billet = @payment.source if @payment.present?
      head 404, content_type: 'text/html' unless @billet.present?
    end

    def authorize
      authorize! :show, @billet.order, session[:access_token]
    end
  end
end
