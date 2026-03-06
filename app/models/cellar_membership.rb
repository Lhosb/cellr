class CellarMembership < ApplicationRecord
  belongs_to :cellar
  belongs_to :user

  enum :role, { owner: 0, editor: 1, viewer: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :cellar_id }
end
