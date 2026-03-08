class CellarEntry < ApplicationRecord
  belongs_to :cellar
  belongs_to :wine

  has_many :drinking_records, dependent: :restrict_with_exception

  enum :state, { in_cellar: 0, drunk: 1 }, default: :in_cellar

  delegate :winery, :wine_name, :varietal, :wine_type, to: :wine, allow_nil: true

  def self.from_wine!(wine)
    cellar_id = wine.cellar_entries.order(:id).pick(:cellar_id)
    raise ArgumentError, "Cannot infer cellar for wine ##{wine.id}" if cellar_id.blank?

    entry = find_or_initialize_by(cellar_id:, wine_id: wine.id)
    entry.assign_attributes(
      vintage: wine.vintage,
      purchase_price_cents: wine.purchase_price_cents,
      state: wine.state,
      drunk_at: wine.drunk_at,
      bottle_size_ml: wine.bottle_size_ml,
      notes: wine.notes,
      tasting_notes: wine.tasting_notes
    )
    entry.save!
    entry
  end

  def self.restore_for_cellar!(wine:, cellar:)
    template_entry = wine.cellar_entries.where(cellar_id: cellar.id).order(updated_at: :desc, id: :desc).first

    entry = new(cellar:, wine:)
    entry.assign_attributes(
      vintage: template_entry&.vintage || wine.vintage,
      purchase_price_cents: template_entry&.purchase_price_cents || wine.purchase_price_cents || 0,
      bottle_size_ml: template_entry&.bottle_size_ml || wine.bottle_size_ml,
      notes: template_entry&.notes || wine.notes,
      tasting_notes: template_entry&.tasting_notes || wine.tasting_notes,
      state: :in_cellar,
      drunk_at: nil
    )
    entry.save!
    entry
  end

  def region
    wine&.region_name
  end
end
