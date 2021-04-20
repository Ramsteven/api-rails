class AccessTokenSerializer < ActiveModel::Serializer
 include JSONAPI::Serializer
  attributes :token
end
