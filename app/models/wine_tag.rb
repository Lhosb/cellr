class WineTag < ApplicationRecord
  belongs_to :wine
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :wine_id }
end
