class ExpensesController < ApplicationController
    # Main page - shows all your expenses and adds up the total
    def index
        @expenses = Expense.all.order(date: :desc)  # Get all expenses, newest ones first
        @total_price = @expenses.sum(:price)        # Add up all the prices to show total
    end

    # Shows the page where you can add a new expense
    def new
        @expense = Expense.new  # Make a blank expense for the form
    end

    # When you click "Save" on the new expense form
    def create
        @expense = Expense.new(expense_params)  # Make a new expense with the info you typed
        if @expense.save
            redirect_to expenses_path, notice: "Expense added successfully."
        else
            render :new  # Show the form again if something went wrong
        end
    end

    # Shows the page where you can edit several expenses at once
    # This happens when you check some boxes and click "Edit Selected"
    def edit_multiple
        # Find all the expenses you checked
        @expenses = Expense.where(id: params[:selected_ids])
    end

    # When you click "Save All Changes" on the edit page
    # This updates all the expenses you changed
    def update_multiple
        # Go through each expense you edited
        params[:expenses].each do |id, attributes|
            expense = Expense.find(id)  # Find the specific expense
            # Save the changes you made (only the safe ones)
            expense.update(attributes.permit(:date, :description, :price, :category))
        end
        redirect_to expenses_path, notice: "Expenses updated successfully."
    end

    # When you click "Delete Selected" button
    # This removes all the expenses you checked
    def destroy_multiple
        # The IDs come as a list separated by commas from the webpage
        # Split them up and clean them
        selected_ids = params[:selected_ids].to_s.split(",").map(&:strip).reject(&:blank?)
        Expense.where(id: selected_ids).destroy_all  # Delete all the selected expenses
        redirect_to expenses_path, notice: "Selected expenses deleted successfully."
    end

    private

    # Safety check: Only allow these specific fields to be saved
    # This stops bad people from changing things they shouldn't
    def expense_params
        params.require(:expense).permit(:date, :description, :price, :category)
    end
end
