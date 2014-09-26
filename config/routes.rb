Spree::Core::Engine.routes.draw do
  # For focas payment method.
  post '/orders/:order_id/checkout/focas_notify/:payment_method_id', to: 'checkout#focas_notify', as: :focas_notify_order_checkout  #, constraints: { protocol: 'https' }
  get 'redirect_to_focas/:id.:payment_method_id', to: 'checkout#redirect_to_focas', as: :redirect_to_focas
end
