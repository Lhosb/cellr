module ApplicationHelper
  def wine_winery_name(wine)
    record = wine.respond_to?(:wine) ? wine.wine : wine
    record&.winery&.name
  end

  def bottle_size_options
    [
      [ "Split / Piccolo (187.5 ml) — 0.25× standard", 187 ],
      [ "Demi / Half (375 ml) — 0.5× standard", 375 ],
      [ "Standard (750 ml) — 1× standard", 750 ],
      [ "Liter (1 L) — 1.33× standard", 1000 ],
      [ "Magnum (1.5 L) — 2× standard", 1500 ],
      [ "Double Magnum (3 L) — 4× standard", 3000 ],
      [ "Jeroboam (4.5 L) — 6× standard", 4500 ],
      [ "Methuselah (6 L) — 8× standard", 6000 ],
      [ "Salmanazar (9 L) — 12× standard", 9000 ],
      [ "Balthazar (12 L) — 16× standard", 12000 ],
      [ "Nebuchadnezzar (16 L) — 20× standard", 16000 ]
    ]
  end

  def wine_type_key(value)
    normalized = value.to_s.strip.downcase

    return "rose" if normalized.include?("ros")

    allowed = %w[red white rose sparkling dessert fortified]
    allowed.include?(normalized) ? normalized : "red"
  end

  def wine_type_pill_class(value)
    "type-pill--#{wine_type_key(value)}"
  end

  def wine_type_dot_class(value)
    "type-pill__dot--#{wine_type_key(value)}"
  end

  def wine_drink_status_key(wine)
    return "ready" if wine.vintage.blank?

    age = Time.current.year - wine.vintage
    age >= 3 ? "ready" : "aging"
  end

  def wine_drink_status_label(wine)
    wine_drink_status_key(wine) == "ready" ? "Drink now" : "Age 1–2 yrs"
  end

  def drink_status_feature_enabled?
    return false unless defined?(Flipper)

    Flipper.enabled?(:drink_status)
  rescue StandardError
    false
  end
end
