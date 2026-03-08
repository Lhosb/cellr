class DrinkingSession < ApplicationRecord
  DRUNK_LEVELS = {
    1 => "Getting started",
    2 => "Feeling it",
    3 => "Might be drunk",
    4 => "Definitely drunk"
  }.freeze

  belongs_to :user

  has_many :drinking_records, dependent: :destroy
  has_many :cellar_entries, through: :drinking_records

  validates :date, :started_at, :last_activity_at, presence: true

  scope :for_date, ->(date) { where(date:) }
  scope :active, -> { where(ended_at: nil) }
  scope :today_active, -> { for_date(Date.current).active }

  def status_label
    return "Just started" if drinking_records.size.zero?

    DRUNK_LEVELS.fetch([ drinking_records.size, 4 ].min)
  end
end
