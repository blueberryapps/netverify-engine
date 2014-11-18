# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :validation, class: 'Netverify::Validation' do
    validatable_id 1
    validatable_type 'User'
    state nil
    jumio_id_scan_reference 'MyString'
    merchant_id_scan_reference 'MyString'
    personal_information {}
    error_types {}
    images {}
  end
end
