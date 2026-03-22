class Wine < ApplicationRecord
  include PgSearch::Model

  belongs_to :winery
  belongs_to :region_record, class_name: "Region", foreign_key: :region_id, inverse_of: :wines, optional: true
  has_many :cellar_entries, dependent: :restrict_with_exception
  has_many :cellars, through: :cellar_entries

  has_many :wine_tags, dependent: :destroy
  has_many :tags, through: :wine_tags
  has_many :drinking_records, through: :cellar_entries

  enum :state, { in_cellar: 0, drunk: 1 }, default: :in_cellar

  before_validation :normalize_identity
  after_commit :sync_pending_cellar_entry_attributes, on: [ :create, :update ]

  validates :winery, :name, presence: true

  pg_search_scope :search_text,
                  against: { name: "A", varietal: "B", wine_type: "B", notes: "C", tasting_notes: "C" },
                  associated_against: { winery: :name, region_record: :name, tags: :name },
                  using: { tsearch: { prefix: true }, trigram: {} }

  def self.duplicate_candidates_for(cellar:, winery:, wine_name:, vintage: nil)
    normalized_winery = normalize_for_key(winery)
    normalized_wine_name = normalize_for_key(wine_name)
    scope = joins(:cellar_entries, :winery).where(cellar_entries: { cellar_id: cellar.id }).distinct

    exact = scope.where("LOWER(wineries.name) = ? AND LOWER(wines.name) = ?", normalized_winery, normalized_wine_name)
    return exact if exact.exists?

    scope.where("LOWER(wineries.name) LIKE :winery OR LOWER(wines.name) LIKE :wine_name", winery: "%#{normalized_winery}%", wine_name: "%#{normalized_wine_name}%")
         .limit(10)
  end

  def self.normalize_for_key(value)
    value.to_s.strip.downcase.gsub(/\s+/, " ")
  end

  def region_name
    region_record&.name
  end

  def region
    region_name
  end

  def region=(value)
    normalized = value.to_s.strip
    self.region_record = Region.find_or_create_normalized(normalized.presence || Region::UNKNOWN_NAME)
  end

  def wine_name
    name
  end

  def wine_name=(value)
    self.name = value
  end

  def vintage
    primary_cellar_entry&.vintage
  end

  def purchase_price_cents
    primary_cellar_entry&.purchase_price_cents
  end

  def vintage=(value)
    pending_cellar_entry_attributes[:vintage] = value
  end

  def purchase_price_cents=(value)
    pending_cellar_entry_attributes[:purchase_price_cents] = value
  end

  def as_json(options = nil)
    super(options).merge("wine_name" => wine_name)
  end

  private

  def pending_cellar_entry_attributes
    @pending_cellar_entry_attributes ||= {}
  end

  def primary_cellar_entry
    if cellar_entries.loaded?
      cellar_entries.first
    else
      cellar_entries.order(:id).first
    end
  end

  def sync_pending_cellar_entry_attributes
    return if @pending_cellar_entry_attributes.blank?

    cellar_entry = primary_cellar_entry
    return unless cellar_entry

    cellar_entry.update!(@pending_cellar_entry_attributes.compact)
    @pending_cellar_entry_attributes = {}
  end

  def normalize_identity
    self.name = name.to_s.strip
    self.varietal = varietal.to_s.strip if varietal.present?
    self.wine_type = wine_type.to_s.strip if wine_type.present?

    resolved_region_name = region_record&.name
    self.region_record = Region.find_or_create_normalized(resolved_region_name.presence || Region::UNKNOWN_NAME)
  end
end
