class CellarMembership < ApplicationRecord
  belongs_to :cellar
  belongs_to :user

  enum :role, { owner: 0, editor: 1, viewer: 2 }

  scope :default_for_user, -> { where(default: true) }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :cellar_id }

  def default_state
    self.default? ? :default : :not_default
  end
end
