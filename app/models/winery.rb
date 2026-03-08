class Winery < ApplicationRecord
  has_many :wines, dependent: :restrict_with_error

  before_validation :normalize_fields

  validates :name, :normalized_name, presence: true
  validates :normalized_name, uniqueness: true

  def self.normalize_name(value)
    value.to_s.strip.downcase.gsub(/\s+/, " ")
  end

  def self.find_or_create_normalized(name)
    return nil if name.to_s.strip.blank?

    stripped_name = name.to_s.strip
    normalized = normalize_name(stripped_name)

    find_or_initialize_by(normalized_name: normalized).tap do |winery|
      winery.name = stripped_name if winery.new_record?
      winery.save!
    end
  end

  private

  def normalize_fields
    self.name = name.to_s.strip
    self.normalized_name = self.class.normalize_name(name)
  end
end
