FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "jsmith#{n}" }
    name {"Jhon Smith"}
    url {"hhtp://example.com"}
    avatar_url {"http://example.com/avatar"} 
    provider {  "github" }
  end
end
