class Expense < ApplicationRecord
  belongs_to :user

  # Predefined categories for consistent categorization
  CATEGORIES = [
    "Food & Dining",
    "Beverage/Drink",
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
    if expenses.is_a?(ActiveRecord::Relation)
      expenses.reorder(nil).group(:category).sum(:price)
    else
      # Array of hashes or OpenStructs
      expenses.group_by { |e| e.category }.transform_values { |arr| arr.sum { |e| e.price.to_f } }
    end
  end

  def self.category_percentages(expenses = all)
    if expenses.is_a?(ActiveRecord::Relation)
      total = expenses.sum(:price)
      return {} if total.zero?
      expenses.reorder(nil).group(:category).sum(:price).transform_values { |amount| (amount / total.to_f * 100).round(1) }
    else
      total = expenses.sum { |e| e.price.to_f }
      return {} if total.zero?
      expenses.group_by { |e| e.category }.transform_values { |arr| ((arr.sum { |e| e.price.to_f } / total.to_f) * 100).round(1) }
    end
  end

  # Returns an array of hashes for each past month of the current year with totals
  def self.monthly_totals_up_to_now(user = nil)
    now = Date.current
    (1..now.month).map do |month|
      scope = by_month(now.year, month)
      scope = scope.where(user: user) if user
      {
        month: Date::MONTHNAMES[month],
        total: scope.sum(:price)
      }
    end
  end
end
