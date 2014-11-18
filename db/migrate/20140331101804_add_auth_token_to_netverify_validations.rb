class AddAuthTokenToNetverifyValidations < ActiveRecord::Migration
  def change
    add_column :netverify_validations, :authorization_token, :string
    add_column :netverify_validations, :auth_type, :string
  end
end
