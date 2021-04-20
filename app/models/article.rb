class Article < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
