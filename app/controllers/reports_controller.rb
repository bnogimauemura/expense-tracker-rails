class ReportsController < ApplicationController
  before_action :authenticate_user!

  # GET /reports/monthly_comparison
  def monthly_comparison
    # Check if this is first visit of the month
    first_visit_detector = FirstVisitDetectorService.new(current_user)
    is_first_visit = first_visit_detector.update_visit_date!
    should_show_report = first_visit_detector.should_show_monthly_report?

    # Get monthly comparison data
    spending_service = MonthlySpendingService.new(current_user)
    comparison_data = spending_service.monthly_comparison

    render json: {
      success: true,
      data: {
        comparison: comparison_data,
        first_visit_of_month: is_first_visit,
        should_show_monthly_report: should_show_report,
        report_month: first_visit_detector.report_month_name
      }
    }
  end
end
