class Cellar < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :owned_cellars

  has_many :cellar_memberships, dependent: :destroy
  has_many :members, through: :cellar_memberships, source: :user
  has_many :wines, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :cellar_invitations, dependent: :destroy

  validates :name, presence: true
end
