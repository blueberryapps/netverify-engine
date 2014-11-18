Netverify::Engine.routes.draw do
  post 'validations/callback', to: 'validations#callback'
  get 'validations/success', to: 'validations#success'
  get 'validations/error', to: 'validations#error'

  get 'documents/success', to: 'documents#success'
  get 'documents/error', to: 'documents#error'
  post 'documents/callback', to: 'documents#callback'
end
