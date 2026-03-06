module Cellars
  class AcceptInvitation
    class InvitationError < StandardError; end

    def self.call(token:, user:)
      invitation = CellarInvitation.pending.find_by(token:)
      raise InvitationError, "Invitation not found or already accepted" unless invitation

      unless invitation.email.casecmp?(user.email)
        raise InvitationError, "Invitation email does not match user"
      end

      CellarMembership.transaction do
        membership = CellarMembership.find_or_initialize_by(cellar: invitation.cellar, user:)
        membership.role = invitation.role
        membership.save!

        invitation.update!(accepted_at: Time.current)
        membership
      end
    end
  end
end
