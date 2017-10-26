Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  post '/moip_notification/:token',
       to: 'moip_notification#update',
       as: 'moip_webhook',
       defaults: { format: :json }
end
