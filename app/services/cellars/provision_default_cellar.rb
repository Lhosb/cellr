module Cellars
  class ProvisionDefaultCellar
    def self.call(user:)
      Cellar.transaction do
        existing_membership = user.cellar_memberships.includes(:cellar).find_by(role: :owner)
        return existing_membership.cellar if existing_membership

        cellar = Cellar.create!(owner: user, name: default_name_for(user))
        CellarMembership.create!(cellar:, user:, role: :owner)
        cellar
      end
    end

    def self.default_name_for(user)
      user.name.presence ? "#{user.name}'s Cellar" : "My Cellar"
    end

    private_class_method :default_name_for
  end
end
