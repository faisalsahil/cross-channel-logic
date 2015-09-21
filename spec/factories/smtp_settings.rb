# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :smtp_setting do
    address "MyString"
    port 1
    domain "MyString"
    user_name "MyString"
    password "MyString"
    authentication "MyString"
    enable_starttls_auto false
  end
end
