class Wine < ApplicationRecord
  include PgSearch::Model

  belongs_to :cellar
  belongs_to :winery
  belongs_to :region_record, class_name: "Region", foreign_key: :region_id, inverse_of: :wines, optional: true

  has_one :cellar_entry, dependent: :destroy

  has_many :wine_tags, dependent: :destroy
  has_many :tags, through: :wine_tags
  has_many :drinking_records, through: :cellar_entry

  enum :state, { in_cellar: 0, drunk: 1 }, default: :in_cellar

  before_validation :normalize_identity

  validates :winery, :wine_name, :normalized_winery, :normalized_wine_name, :canonical_key, presence: true

  pg_search_scope :search_text,
                  against: { normalized_winery: "A", wine_name: "A", region: "B", varietal: "B", notes: "C", tasting_notes: "C" },
                  associated_against: { tags: :name },
                  using: { tsearch: { prefix: true }, trigram: {} }

  def self.duplicate_candidates_for(cellar:, winery:, wine_name:, vintage: nil)
    scope = where(cellar:)

    normalized_winery = normalize_for_key(winery)
    normalized_wine_name = normalize_for_key(wine_name)
    key = [ normalized_winery, normalized_wine_name, vintage.presence || "nv" ].join("|")

    exact = scope.where(canonical_key: key)
    return exact if exact.exists?

    scope.where("normalized_winery LIKE :winery OR normalized_wine_name LIKE :wine_name", winery: "%#{normalized_winery}%", wine_name: "%#{normalized_wine_name}%")
         .limit(10)
  end

  def self.normalize_for_key(value)
    value.to_s.strip.downcase.gsub(/\s+/, " ")
  end

  def region_name
    region_record&.name
  end

  private

  def normalize_identity
    self.wine_name = wine_name.to_s.strip
    self.varietal = varietal.to_s.strip if varietal.present?

    resolved_region_name = region.presence || region_record&.name
    self.region_record = Region.find_or_create_normalized(resolved_region_name.presence || Region::UNKNOWN_NAME)
    self.region = region_record&.name

    self.normalized_winery = self.class.normalize_for_key(winery&.name)
    self.normalized_wine_name = self.class.normalize_for_key(wine_name)

    normalized_vintage = vintage.presence || "nv"
    self.canonical_key = [ normalized_winery, normalized_wine_name, normalized_vintage ].join("|")
  end
end
