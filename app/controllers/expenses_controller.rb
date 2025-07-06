require "ostruct"
require_relative "../services/first_visit_detector_service"
require_relative "../services/monthly_spending_service"

class ExpensesController < ApplicationController
    # Main page - shows current month expenses and adds up the total
    def index
        if user_signed_in?
            @expenses = current_user.expenses.current_month.order(date: :desc)

            # Get monthly report data
            first_visit_detector = FirstVisitDetectorService.new(current_user)
            @should_show_monthly_report = first_visit_detector.should_show_monthly_report?
            @report_month = first_visit_detector.report_month_name

            if @should_show_monthly_report
                spending_service = MonthlySpendingService.new(current_user)
                @monthly_comparison = spending_service.monthly_comparison
            end

            # Update visit date after checking if we should show the report
            @is_first_visit = first_visit_detector.update_visit_date!
        else
            session[:guest_expenses] ||= []
            @expenses = session[:guest_expenses].map { |e| OpenStruct.new(e) }
        end
        @total_price = @expenses.sum { |e| e.price.to_f }

        # Get category totals for the current month
        @category_totals = Expense.total_by_category(@expenses)
        @category_percentages = Expense.category_percentages(@expenses)

        # Get monthly totals for each past month of the current year
        @monthly_totals = Expense.monthly_totals_up_to_now(user_signed_in? ? current_user : nil)
    end

    # Shows the page where you can add a new expense
    def new
        @expense = Expense.new  # Make a blank expense for the form
    end

    # When you click "Save" on the new expense form
    def create
        if user_signed_in?
            @expense = Expense.new(expense_params)  # Make a new expense with the info you typed
            @expense.user = current_user
            if @expense.save
                redirect_to expenses_path, notice: "Expense added successfully."
            else
                render :new  # Show the form again if something went wrong
            end
        else
            session[:guest_expenses] ||= []
            guest_expense = expense_params.to_h
            guest_expense["id"] = SecureRandom.uuid
            session[:guest_expenses] << guest_expense
            redirect_to expenses_path, notice: "Expense added successfully."
        end
    end

    # Shows the page where you can edit several expenses at once
    # This happens when you check some boxes and click "Edit Selected"
    def edit_multiple
        if user_signed_in?
            @expenses = current_user.expenses.where(id: params[:selected_ids])
        else
            session[:guest_expenses] ||= []
            ids = Array(params[:selected_ids])
            @expenses = session[:guest_expenses].select { |e| ids.include?(e["id"]) }.map { |e| OpenStruct.new(e) }
        end
    end

    # When you click "Save All Changes" on the edit page
    # This updates all the expenses you changed
    def update_multiple
        if user_signed_in?
            params[:expenses].each do |id, attributes|
                expense = current_user.expenses.find_by(id: id)
                expense&.update(attributes.permit(:date, :description, :price, :category))
            end
        else
            session[:guest_expenses] ||= []
            params[:expenses].each do |id, attributes|
                idx = session[:guest_expenses].index { |e| e["id"] == id }
                session[:guest_expenses][idx].merge!(attributes.to_h) if idx
            end
        end
        redirect_to expenses_path, notice: "Expenses updated successfully."
    end

    # When you click "Delete Selected" button
    # This removes all the expenses you checked
    def destroy_multiple
        if user_signed_in?
            selected_ids = params[:selected_ids].to_s.split(",").map(&:strip).reject(&:blank?)
            current_user.expenses.where(id: selected_ids).destroy_all  # Delete all the selected expenses
        else
            session[:guest_expenses] ||= []
            selected_ids = params[:selected_ids].to_s.split(",").map(&:strip).reject(&:blank?)
            session[:guest_expenses].delete_if { |e| selected_ids.include?(e["id"]) }
        end
        redirect_to expenses_path, notice: "Selected expenses deleted successfully."
    end

    def new_multiple
        items = session[:selected_receipt_items] || []
        if items.empty?
            flash[:alert] = "No receipt items to add. Please scan a receipt first."
            return redirect_to expenses_path
        end
        @expenses = items.map do |item|
            Expense.new(
                description: item["name"],
                price: item["price"],
                category: item["category"],
                date: item["date"] || Date.current
            )
        end
    end

    def create_multiple
        expense_params = params[:expenses] || []
        @expenses = expense_params.map do |exp|
            current_user.expenses.build(exp.permit(:description, :price, :category, :date))
        end
        if @expenses.all?(&:valid?)
            @expenses.each(&:save!)
            session.delete(:selected_receipt_items)
            flash[:notice] = "Expenses added successfully!"
            redirect_to expenses_path
        else
            flash.now[:alert] = "Please correct the errors below."
            render :new_multiple, status: :unprocessable_entity
        end
    end

    private

    # Safety check: Only allow these specific fields to be saved
    # This stops bad people from changing things they shouldn't
    def expense_params
        params.require(:expense).permit(:date, :description, :price, :category)
    end
end
