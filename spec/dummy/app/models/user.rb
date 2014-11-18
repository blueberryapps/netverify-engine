class User < ActiveRecord::Base
  include Netverify::Callbacks

  has_one :validation, as: :validatable, class_name: 'Netverify::Validation'
end
