class CellarInvitation < ApplicationRecord
  belongs_to :cellar
  belongs_to :invited_by, class_name: "User"

  enum :role, { owner: 0, editor: 1, viewer: 2 }

  before_validation :ensure_token

  validates :email, presence: true
  validates :token, presence: true, uniqueness: true

  scope :pending, -> { where(accepted_at: nil) }

  private

  def ensure_token
    self.token ||= SecureRandom.hex(16)
  end
end
