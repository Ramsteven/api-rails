class ArticleSerializer
  include JSONAPI::Serializer
    attribute :title 
    attribute :content
    attribute :slug
end
