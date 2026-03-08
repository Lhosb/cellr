class CellarEntry < ApplicationRecord
  belongs_to :cellar
  belongs_to :wine

  has_many :drinking_records, dependent: :restrict_with_exception

  enum :state, { in_cellar: 0, drunk: 1 }, default: :in_cellar

  delegate :winery, :wine_name, :varietal, :wine_type, to: :wine, allow_nil: true

  def self.from_wine!(wine)
    entry = find_or_initialize_by(cellar_id: wine.cellar_id, wine_id: wine.id)
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

  def region
    wine&.region_name
  end
end
