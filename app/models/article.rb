class Article < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true
  belongs_to :user
  scope :recent, -> { order(created_at: :desc) }
end
