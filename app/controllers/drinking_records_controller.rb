class DrinkingRecordsController < ApplicationController
  def create
    wine = accessible_wines.find(create_params[:cellar_entry_id])

    DrinkingRecords::Create.call(
      user: current_user,
      cellar_entry: wine,
      consumed_at: consumed_at,
      tasting_notes: create_params[:tasting_notes],
      quantity: create_params[:quantity]
    )

    redirect_to happy_hour_path, notice: "Drink logged"
  rescue ActiveRecord::RecordInvalid => error
    redirect_to happy_hour_path, alert: error.record.errors.full_messages.to_sentence
  end

  private

  def create_params
    params.require(:drinking_record).permit(:cellar_entry_id, :tasting_notes, :quantity, :consumed_at)
  end

  def consumed_at
    return Time.current if create_params[:consumed_at].blank?

    Time.zone.parse(create_params[:consumed_at])
  rescue ArgumentError, TypeError
    Time.current
  end

  def accessible_wines
    Wine.joins(:cellars)
      .left_outer_joins(cellars: :cellar_memberships)
      .where("cellars.owner_id = :user_id OR cellar_memberships.user_id = :user_id", user_id: current_user.id)
      .distinct
  end
end
