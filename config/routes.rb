Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  post '/moip_notification/:token',
       to: 'moip_notification#update',
       as: 'moip_webhook',
       defaults: { format: :json }

  get '/boleto/:payment',
      to: 'moip_billet#show',
      as: 'moip_billet'
  end
