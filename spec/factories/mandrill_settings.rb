# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mandrill_setting do
    subject "MyString"
    user_name "MyString"
    email "MyString"
  end
end
