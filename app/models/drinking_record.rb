class DrinkingRecord < ApplicationRecord
  belongs_to :drinking_session
  belongs_to :cellar_entry, class_name: "Wine"

  validates :consumed_at, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
