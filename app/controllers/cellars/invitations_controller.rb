module Cellars
  class InvitationsController < ApplicationController
    def create
      cellar = Cellar.find(params.require(:cellar_id))
      invited_by = User.find(params.require(:invited_by_id))

      invitation = cellar.cellar_invitations.create!(
        email: params.require(:email),
        invited_by:,
        role: invitation_role
      )

      render json: invitation.as_json(only: [:id, :cellar_id, :email, :role, :token, :accepted_at]), status: :created
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def accept
      user = User.find(params.require(:user_id))
      membership = Cellars::AcceptInvitation.call(token: params.require(:token), user:)

      render json: membership.as_json(only: [:id, :cellar_id, :user_id, :role]), status: :ok
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue Cellars::AcceptInvitation::InvitationError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    private

    def invitation_role
      params[:role].presence || :viewer
    end
  end
end