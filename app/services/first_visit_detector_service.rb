class FirstVisitDetectorService
  def initialize(user)
    @user = user
  end

  # Check if this is the first visit of the current month
  def first_visit_of_month?
    return true if @user.last_visit_date.nil?

    current_month = Date.current.beginning_of_month
    last_visit_month = @user.last_visit_date.beginning_of_month

    current_month > last_visit_month
  end

  # Update the user's last visit date and return if it was first visit
  def update_visit_date!
    was_first_visit = first_visit_of_month?

    @user.update!(last_visit_date: Time.current)

    was_first_visit
  end

  # Get the month name for the report (the last completed month)
  def report_month_name
    1.month.ago.strftime("%B")
  end

  # Check if user should see monthly report
  def should_show_monthly_report?
    first_visit_of_month? && has_expenses_in_last_month?
  end

  private

  def has_expenses_in_last_month?
    last_month_start = 1.month.ago.beginning_of_month
    last_month_end = 1.month.ago.end_of_month

    @user.expenses.where(date: last_month_start..last_month_end).exists?
  end
end
