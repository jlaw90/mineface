PiMiner::Application.routes.draw do
  root :to => 'home#index'
  get 'chart', to: 'home#chart'
  get 'overview', to: 'home#overview'
end
