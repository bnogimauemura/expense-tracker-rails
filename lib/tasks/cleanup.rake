namespace :cleanup do
  desc "Delete all expenses without a user"
  task delete_orphan_expenses: :environment do
    count = Expense.where(user_id: nil).delete_all
    puts "Deleted \\#{count} orphan expenses."
  end
end 