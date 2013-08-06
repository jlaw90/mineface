PiMiner::Application.routes.draw do
  root :to => 'home#index'
  get 'chart', to: 'home#chart'
  get 'overview', to: 'home#overview'
  get 'devices', to: 'home#devices'
  get 'pools', to: 'home#pools'

  # Device management
  match '/device/:id', to: 'device#show', as: 'show_device'
  match '/device/:id/disable', to: 'device#disable', as: 'disable_device'
  match '/device/:id/enable', to: 'device#enable', as: 'enable_device'

  # Pool management
  match '/pool/:id/disable', to: 'pool#disable', as: 'disable_pool'
  match '/pool/:id/enable', to: 'pool#enable', as: 'enable_pool'
  match '/pool/:id/delete', to: 'pool#delete', as: 'delete_pool'
  match '/pool/new', to: 'pool#new', as: 'new_pool'
  match '/pool/create', to: 'pool#create', as: 'create_pool'
  match '/pool/:id/update', to: 'pool#update', as: 'update_pool'
end