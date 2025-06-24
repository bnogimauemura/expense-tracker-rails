class ExpensesController < ApplicationController
    def index
        @expenses = Expense.all.order(date: :desc)
        @total_price = @expenses.sum(:price)
    end

    def new 
        @expense = Expense.new
    end

    def create
        @expense = Expense.new(expense_params)
        if @expense.save
            redirect_to expenses_path, notice: "Expense added successfully."
        else
            render :new
        end
    end

    private

    def expense_params
        params.require(:expense).permit(:date, :description, :price, :category)
    end
end
