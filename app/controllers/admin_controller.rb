class AdminController < ApplicationController
  # WARNING: Remove this after running once!
  def cleanup_orphan_expenses
    count = Expense.where(user_id: nil).delete_all
    render plain: "Deleted \\#{count} orphan expenses."
  end
end 