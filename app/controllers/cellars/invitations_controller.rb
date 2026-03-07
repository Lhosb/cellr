module Cellars
  class InvitationsController < ApplicationController
    def show
      @invitation = CellarInvitation.find_by(token: params.require(:token))

      if @invitation.nil?
        redirect_to root_path, alert: "Invitation not found"
        return
      end

      @can_accept = @invitation.accepted_at.nil? && @invitation.email.casecmp?(current_user.email)
    end

    def index
      cellar = Cellar.find(params.require(:cellar_id))
      invitations = cellar.cellar_invitations.pending.order(created_at: :desc)

      render json: invitations.as_json(only: [ :id, :cellar_id, :email, :role, :token, :accepted_at ]), status: :ok
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def create
      cellar = Cellar.find(params.require(:cellar_id))
      invited_by = User.find(params.require(:invited_by_id))

      invitation = cellar.cellar_invitations.create!(
        email: params.require(:email),
        invited_by:,
        role: invitation_role
      )

      respond_to do |format|
        format.html { redirect_to cellar_path(cellar), notice: "Invitation created" }
        format.json { render json: invitation.as_json(only: [ :id, :cellar_id, :email, :role, :token, :accepted_at ]), status: :created }
      end
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def accept
      token = params.require(:token)
      user = params[:user_id].present? ? User.find(params.require(:user_id)) : current_user
      membership = Cellars::AcceptInvitation.call(token:, user:)

      respond_to do |format|
        format.html { redirect_to cellar_path(membership.cellar), notice: "Invitation accepted" }
        format.json { render json: membership.as_json(only: [ :id, :cellar_id, :user_id, :role ]), status: :ok }
      end
    rescue Cellars::AcceptInvitation::InvitationError => e
      respond_to do |format|
        format.html { redirect_to cellar_invitation_token_path(params[:token]), alert: e.message }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    rescue ActiveRecord::RecordNotFound => e
      respond_to do |format|
        format.html { redirect_to root_path, alert: e.message }
        format.json { render json: { error: e.message }, status: :not_found }
      end
    rescue ActionController::ParameterMissing => e
      respond_to do |format|
        format.html { redirect_to root_path, alert: e.message }
        format.json { render json: { error: e.message }, status: :bad_request }
      end
    end

    def destroy
      cellar = Cellar.find(params.require(:cellar_id))
      invitation = cellar.cellar_invitations.find(params.require(:id))
      invitation.destroy!

      respond_to do |format|
        format.html { redirect_to cellar_path(cellar), notice: "Invitation revoked" }
        format.json { head :no_content }
      end
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    private

    def invitation_role
      params[:role].presence || :viewer
    end
  end
end
