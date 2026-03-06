class Wine < ApplicationRecord
  include PgSearch::Model

  belongs_to :cellar

  has_many :wine_tags, dependent: :destroy
  has_many :tags, through: :wine_tags

  before_validation :normalize_identity

  validates :winery, :wine_name, :normalized_winery, :normalized_wine_name, :canonical_key, presence: true
  validates :canonical_key, uniqueness: { scope: :cellar_id }

  pg_search_scope :search_text,
                  against: { winery: "A", wine_name: "A", region: "B", varietal: "B" },
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

  private

  def normalize_identity
    self.winery = winery.to_s.strip
    self.wine_name = wine_name.to_s.strip
    self.varietal = varietal.to_s.strip if varietal.present?
    self.region = region.to_s.strip if region.present?

    self.normalized_winery = self.class.normalize_for_key(winery)
    self.normalized_wine_name = self.class.normalize_for_key(wine_name)

    normalized_vintage = vintage.presence || "nv"
    self.canonical_key = [ normalized_winery, normalized_wine_name, normalized_vintage ].join("|")
  end
end
