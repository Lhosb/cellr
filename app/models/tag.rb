class Tag < ApplicationRecord
  belongs_to :cellar

  has_many :wine_tags, dependent: :destroy
  has_many :wines, through: :wine_tags

  validates :name, presence: true, uniqueness: { scope: :cellar_id }
end
