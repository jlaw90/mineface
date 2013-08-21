PiMiner::Application.routes.draw do
  root :to => 'home#index'
  get '/chart(.:format)', to: 'home#chart'
  get '/overview(.:format)', to: 'home#overview'
  get '/devices(.:format)', to: 'home#devices'
  get '/pools(.:format)', to: 'home#pools'

  # Device management
  get '/device/:type/:id(.:format)', to: 'device#show', as: 'show_device'
  get '/device/:type/:id/disable(.:format)', to: 'device#disable', as: 'disable_device'
  get '/device/:type/:id/enable(.:format)', to: 'device#enable', as: 'enable_device'

  # Pool management
  get '/pool/:id/disable(.:format)', to: 'pool#disable', as: 'disable_pool'
  get '/pool/:id/enable(.:format)', to: 'pool#enable', as: 'enable_pool'
  get '/pool/:id/delete(.:format)', to: 'pool#delete', as: 'delete_pool'
  get '/pool/new(.:format)', to: 'pool#new', as: 'new_pool'
  get '/pool/create(.:format)', to: 'pool#create', as: 'create_pool'
  get '/pool/:id/priup(.:format)', to: 'pool#up', as: 'pool_up'
  get '/pool/:id/pridown(.:format)', to: 'pool#down', as: 'pool_down'
  get '/pool/:id/update(.:format)', to: 'pool#update', as: 'update_pool'
end