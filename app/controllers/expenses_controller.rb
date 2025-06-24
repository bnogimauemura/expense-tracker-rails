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

    def edit_multiple
        @expenses = Expense.where(id: params[:selected_ids])
    end

    def update_multiple
        params[:expenses].each do |id, attributes|
            expense = Expense.find(id)
            expense.update(attributes.permit(:date, :description, :price, :category))
        end
        redirect_to expenses_path, notice: "Expenses updated successfully."
    end

    def destroy_multiple
        Expense.where(id: params[:selected_ids]).destroy_all
        redirect_to expenses_path, notice: "Selected expenses deleted successfully."
    end

    def destroy
        @expense = Expense.where(params[:selected_ids])
        @expense.destroy_all
        redirect_to expenses_path, notice: "Expense deleted successfully."
    end
    
    private

    def expense_params
        params.require(:expense).permit(:date, :description, :price, :category)
    end
end
