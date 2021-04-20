FactoryBot.define do
  factory :access_token do
    # token { "MyString" }
    # user { nil }
    association :user
  end
end
