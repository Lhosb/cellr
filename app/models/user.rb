class User < ApplicationRecord
  has_many :cellar_memberships, dependent: :destroy
  has_many :cellars, through: :cellar_memberships
  has_many :owned_cellars, class_name: "Cellar", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  after_create_commit :provision_default_cellar

  private

  def provision_default_cellar
    Cellars::ProvisionDefaultCellar.call(user: self)
  end
end
