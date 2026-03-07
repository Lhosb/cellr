class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :cellar_memberships, dependent: :destroy
  has_many :cellars, through: :cellar_memberships
  has_many :owned_cellars, class_name: "Cellar", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

  def pending_invitations
    CellarInvitation.pending.where("LOWER(email) = ?", email.downcase)
  end

  validates :email, presence: true, uniqueness: true

  after_create_commit :provision_default_cellar

  # An "invited" user has been created via invitation but has not yet set a password.
  def invited?
    encrypted_password.blank?
  end

  # An "activated" user has completed registration and set a password.
  def activated?
    encrypted_password.present?
  end

  private

  # Allow creating invited users without passwords.
  # Password becomes required during normal registration or account activation.
  def password_required?
    return false if new_record? && password.blank? && password_confirmation.blank?
    super
  end

  def provision_default_cellar
    Cellars::ProvisionDefaultCellar.call(user: self)
  end
end
