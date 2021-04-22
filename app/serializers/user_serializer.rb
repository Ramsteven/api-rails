class UserSerializer
  include JSONAPI::Serializer
  attributes :id
  attributes :name
end
