class DrinkLoggedNotifier < ApplicationNotifier
  deliver_by :database

  required_param :actor
  required_param :wine

  recipients do
    User.joins(:drinking_sessions)
      .merge(DrinkingSession.today_active)
      .where.not(id: params[:actor].id)
      .distinct
  end

  notification_methods do
    def message
      actor_name = params[:actor].name.presence || params[:actor].email
      wine = params[:wine]
      wine_label = [ wine.winery&.name, wine.wine_name ].compact_blank.join(" · ")

      "#{actor_name} logged #{wine_label}"
    end

    def url
      Rails.application.routes.url_helpers.happy_hour_path
    end
  end
end
