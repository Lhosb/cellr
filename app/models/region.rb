class Region < ApplicationRecord
  has_many :wines, foreign_key: :region_id, inverse_of: :region_record, dependent: :restrict_with_exception

  validates :name, :normalized_name, presence: true
  validates :normalized_name, uniqueness: { case_sensitive: true }

  before_validation :normalize_identity

  UNKNOWN_NAME = "Unknown".freeze

  def self.normalize_for_key(value)
    value.to_s.strip.downcase.gsub(/\s+/, " ")
  end

  def self.find_or_create_normalized(name)
    normalized = normalize_for_key(name)
    raise ArgumentError, "region name cannot be blank" if normalized.blank?

    find_or_create_by!(normalized_name: normalized) do |region|
      region.name = name.to_s.strip
    end
  end

  def self.unknown
    find_or_create_normalized(UNKNOWN_NAME)
  end

  private

  def normalize_identity
    self.name = name.to_s.strip
    self.normalized_name = self.class.normalize_for_key(name)
  end
end
