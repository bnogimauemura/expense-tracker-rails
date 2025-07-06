class MonthlySpendingService
  def initialize(user)
    @user = user
  end

  # Main method to get monthly comparison data (rolling comparison)
  def monthly_comparison
    last_month_data = get_month_data(1.month.ago)
    past_past_month_data = get_month_data(2.months.ago)
    
    build_comparison(last_month_data, past_past_month_data)
  end

  # Get data for a specific month
  def get_month_data(date)
    month_start = date.beginning_of_month
    month_end = date.end_of_month
    
    expenses = @user.expenses.where(date: month_start..month_end)
    
    {
      month: date.strftime("%B"),
      year: date.year,
      total: expenses.sum(:price),
      by_category: expenses.group(:category).sum(:price),
      category_percentages: calculate_category_percentages(expenses)
    }
  end

  # Build comparison hash with changes (last month vs past past month)
  def build_comparison(last_month, past_past_month)
    all_categories = (last_month[:by_category].keys + past_past_month[:by_category].keys).uniq
    
    comparison = {}
    
    all_categories.each do |category|
      last_month_amount = last_month[:by_category][category] || 0
      past_past_month_amount = past_past_month[:by_category][category] || 0
      
      change_percentage = calculate_change_percentage(past_past_month_amount, last_month_amount)
      
      comparison[category] = {
        last_month: last_month_amount,
        past_past_month: past_past_month_amount,
        change_percentage: change_percentage,
        change_direction: change_percentage >= 0 ? '+' : '-'
      }
    end
    
    {
      last_month: last_month[:month],
      past_past_month: past_past_month[:month],
      last_month_total: last_month[:total],
      past_past_month_total: past_past_month[:total],
      total_change_percentage: calculate_change_percentage(past_past_month[:total], last_month[:total]),
      categories: comparison
    }
  end

  private

  def calculate_category_percentages(expenses)
    total = expenses.sum(:price)
    return {} if total.zero?
    
    expenses.group(:category).sum(:price).transform_values do |amount|
      (amount / total.to_f * 100).round(1)
    end
  end

  def calculate_change_percentage(previous, current)
    return 0 if previous.zero?
    
    ((current - previous) / previous.to_f * 100).round(1)
  end
end 