PiMiner::Application.routes.draw do
  root :to => 'home#index'
  match '/chart(.:format)', to: 'home#chart'
  match '/overview(.:format)', to: 'home#overview'
  match '/devices(.:format)', to: 'home#devices'
  match '/pools(.:format)', to: 'home#pools'

  # Device management
  match '/device/:type/:id(.:format)', to: 'device#show', as: 'show_device'
  match '/device/:type/:id/disable(.:format)', to: 'device#disable', as: 'disable_device'
  match '/device/:type/:id/enable(.:format)', to: 'device#enable', as: 'enable_device'

  # Pool management
  match '/pool/:id/disable(.:format)', to: 'pool#disable', as: 'disable_pool'
  match '/pool/:id/enable(.:format)', to: 'pool#enable', as: 'enable_pool'
  match '/pool/:id/delete(.:format)', to: 'pool#delete', as: 'delete_pool'
  match '/pool/new(.:format)', to: 'pool#new', as: 'new_pool'
  match '/pool/create(.:format)', to: 'pool#create', as: 'create_pool'
  match '/pool/:id/priup(.:format)', to: 'pool#up', as: 'pool_up'
  match '/pool/:id/pridown(.:format)', to: 'pool#down', as: 'pool_down'
  match '/pool/:id/update(.:format)', to: 'pool#update', as: 'update_pool'
end