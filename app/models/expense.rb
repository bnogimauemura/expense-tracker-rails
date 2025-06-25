class Expense < ApplicationRecord
  # Predefined categories for consistent categorization
  CATEGORIES = [
    "Food & Dining",
    "Transportation",
    "Shopping",
    "Entertainment",
    "Healthcare",
    "Utilities",
    "Housing",
    "Education",
    "Travel",
    "Other"
  ].freeze

  # Validations
  validates :date, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, inclusion: { in: CATEGORIES }

  # Scopes for filtering
  scope :current_month, -> { where(date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_month, ->(year, month) { where(date: Date.new(year, month).beginning_of_month..Date.new(year, month).end_of_month) }

  # Helper methods
  def self.total_by_category(expenses = all)
    expenses.reorder(nil).group(:category).sum(:price)
  end

  def self.category_percentages(expenses = all)
    total = expenses.sum(:price)
    return {} if total.zero?

    expenses.reorder(nil).group(:category).sum(:price).transform_values { |amount| (amount / total.to_f * 100).round(1) }
  end

  # Returns an array of hashes for each past month of the current year with totals
  def self.monthly_totals_up_to_now
    now = Date.current
    (1..now.month).map do |month|
      {
        month: Date::MONTHNAMES[month],
        total: by_month(now.year, month).sum(:price)
      }
    end
  end
end
