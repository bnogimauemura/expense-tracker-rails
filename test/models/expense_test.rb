require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  
  # Test 1: Valid expense should save successfully
  test "should save valid expense" do
    expense = Expense.new(
      date: Date.current,
      description: "Lunch at restaurant",
      price: 1500,
      category: "Food & Dining"
    )
    
    # assert means "this should be true"
    assert expense.save, "Valid expense should save"
  end
  
  # Test 2: Expense without required fields should not save
  test "should not save expense without required fields" do
    expense = Expense.new
    # assert_not means "this should be false"
    assert_not expense.save, "Expense without required fields should not save"
  end
  
  # Test 3: Test the current_month scope
  test "current_month scope should return only current month expenses" do
    # Create an expense for current month
    current_expense = Expense.create!(
      date: Date.current,
      description: "Current month expense",
      price: 1000,
      category: "Food & Dining"
    )
    
    # Create an expense for last month
    last_month_expense = Expense.create!(
      date: 1.month.ago,
      description: "Last month expense", 
      price: 2000,
      category: "Transportation"
    )
    
    # Get expenses for current month using our scope
    current_month_expenses = Expense.current_month
    
    # Should include current month expense
    assert_includes current_month_expenses, current_expense
    # Should NOT include last month expense
    assert_not_includes current_month_expenses, last_month_expense
  end
  
  # Test 4: Test category totals calculation
  test "should calculate category totals correctly" do
    # Create multiple expenses in same category
    Expense.create!(
      date: Date.current,
      description: "Lunch",
      price: 1000,
      category: "Food & Dining"
    )
    
    Expense.create!(
      date: Date.current, 
      description: "Dinner",
      price: 2000,
      category: "Food & Dining"
    )
    
    # Get category totals for current month using the correct method
    category_totals = Expense.current_month.total_by_category
    
    # Should have Food & Dining with total of 3000
    assert_equal 3000, category_totals["Food & Dining"]
  end
end