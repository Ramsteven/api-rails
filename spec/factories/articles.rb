FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "sample-article-#{n}"}
    content { "Sample content" }
    sequence(:slug) { |n| "sample-article-#{n}"}
  end
end
