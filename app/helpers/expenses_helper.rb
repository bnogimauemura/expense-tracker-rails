module ExpensesHelper
  # Category emoji mapping
  CATEGORY_EMOJIS = {
    "Food & Dining" => "🍚",
    "Beverage/Drink" => "🥤",
    "Transportation" => "🚗",
    "Shopping" => "🛍",
    "Entertainment" => "🎬",
    "Healthcare" => "🏥",
    "Utilities" => "💡",
    "Housing" => "🏠",
    "Education" => "📚",
    "Travel" => "✈️",
    "Other" => "💸"
  }.freeze

  # Format currency amount
  def format_currency(amount)
    "¥#{number_with_delimiter(amount.to_i)}"
  end

  # Format percentage change
  def format_percentage_change(percentage)
    return "0%" if percentage.zero?
    
    direction = percentage > 0 ? "+" : ""
    "#{direction}#{percentage}%"
  end

  # Get emoji for category
  def category_emoji(category)
    CATEGORY_EMOJIS[category] || "💸"
  end

  # Format a single category line for the report
  def format_category_line(category, data)
    emoji = category_emoji(category)
    amount = format_currency(data[:last_month])
    change = format_percentage_change(data[:change_percentage])
    previous_month = data[:past_past_month]
    
    "#{emoji} #{category}: #{amount} (#{change} from #{previous_month})"
  end

  # Generate the full monthly report text
  def generate_monthly_report_text(comparison_data)
    return "No data available" unless comparison_data && comparison_data[:categories]
    
    lines = []
    lines << "#{comparison_data[:last_month]} Report Card"
    lines << ""
    
    comparison_data[:categories].each do |category, data|
      lines << format_category_line(category, data)
    end
    
    lines.join("\n")
  end

  # Check if there's a significant change (more than 5%)
  def significant_change?(percentage)
    percentage.abs > 5
  end

  # Get CSS class for change direction
  def change_direction_class(percentage)
    return "text-success" if percentage > 0
    return "text-danger" if percentage < 0
    "text-muted"
  end
end
