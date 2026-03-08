class DrinkingRecord < ApplicationRecord
  belongs_to :drinking_session
  belongs_to :cellar_entry

  validates :consumed_at, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def cellar_entry=(value)
    resolved = value.is_a?(Wine) ? CellarEntry.from_wine!(value) : value
    super(resolved)
  end
end
