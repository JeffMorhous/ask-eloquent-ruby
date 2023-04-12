Rails.application.routes.draw do
  get 'components/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'components#index'
  post 'questions/ask', to: 'questions#ask'
end
