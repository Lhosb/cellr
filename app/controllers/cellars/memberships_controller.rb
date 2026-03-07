module Cellars
  class MembershipsController < ApplicationController
    def index
      cellar = Cellar.find(params.require(:cellar_id))
      memberships = cellar.cellar_memberships.includes(:user).order(created_at: :asc)

      render json: memberships.map { |membership| serialize_membership(membership) }, status: :ok
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def destroy
      cellar = Cellar.find(params.require(:cellar_id))
      membership = cellar.cellar_memberships.find(params.require(:id))

      if membership.owner?
        respond_to do |format|
          format.html { redirect_to cellar_path(cellar), alert: "Owner membership cannot be removed" }
          format.json { render json: { error: "Owner membership cannot be removed" }, status: :unprocessable_entity }
        end
        return
      end

      membership.destroy!
      respond_to do |format|
        format.html { redirect_to cellar_path(cellar), notice: "Member removed" }
        format.json { head :no_content }
      end
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def update
      cellar = Cellar.find(params.require(:cellar_id))
      membership = cellar.cellar_memberships.find(params.require(:id))

      if membership.owner?
        respond_to do |format|
          format.html { redirect_to cellar_path(cellar), alert: "Owner membership role cannot be changed" }
          format.json { render json: { error: "Owner membership role cannot be changed" }, status: :unprocessable_entity }
        end
        return
      end

      membership.update!(role: params.require(:role))
      respond_to do |format|
        format.html { redirect_to cellar_path(cellar), notice: "Member role updated" }
        format.json { render json: serialize_membership(membership), status: :ok }
      end
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    private

    def serialize_membership(membership)
      {
        id: membership.id,
        cellar_id: membership.cellar_id,
        user_id: membership.user_id,
        role: membership.role,
        user: {
          id: membership.user.id,
          email: membership.user.email,
          name: membership.user.name
        }
      }
    end
  end
end
