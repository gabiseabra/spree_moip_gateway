Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  post '/moip_webhook/:token',
       to: 'moip_webhook#update',
       as: 'moip_webhook'
end
