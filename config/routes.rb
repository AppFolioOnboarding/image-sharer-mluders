Rails.application.routes.draw do
  root 'application#home'
  resources :images, only: %i[index new create show destroy]
end
