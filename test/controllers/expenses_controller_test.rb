require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  # Controller tests check if your controller actions work correctly
  # They test the HTTP requests and responses
  
  # Test 1: Index page should load successfully
  test "should get index" do
    # get is a test helper that simulates a GET request to the index action
    get expenses_url
    
    # assert_response :success means the response should be successful (200 OK)
    assert_response :success
  end
  
  # Test 2: Should be able to create a new expense
  test "should create expense" do
    # assert_difference checks if the count changes by the specified amount
    # In this case, we expect the Expense count to increase by 1
    assert_difference('Expense.count') do
      # post simulates a POST request with the expense data
      post expenses_url, params: { 
        expense: { 
          date: Date.current,
          description: "Test expense",
          price: 1000,
          category: "Food & Dining"
        } 
      }
    end
    
    # After creating, should redirect to the index page
    assert_redirected_to expenses_url
  end
  
  # Test 3: Should not create expense with invalid data
  test "should not create expense with invalid data" do
    # assert_no_difference means the count should NOT change
    assert_no_difference('Expense.count') do
      post expenses_url, params: { 
        expense: { 
          date: nil,  # Invalid: missing date
          description: "",  # Invalid: empty description
          price: nil,  # Invalid: missing price
          category: ""  # Invalid: empty category
        } 
      }
    end
    
    # Should render the form again (200 OK) to show validation errors
    assert_response :success
  end
  
  # Test 4: Should be able to delete multiple expenses
  test "should destroy multiple expenses" do
    # First create expenses to delete
    expense1 = Expense.create!(
      date: Date.current,
      description: "Expense 1 to delete",
      price: 1000,
      category: "Food & Dining"
    )
    
    expense2 = Expense.create!(
      date: Date.current,
      description: "Expense 2 to delete", 
      price: 2000,
      category: "Transportation"
    )
    
    # assert_difference with -2 means we expect the count to decrease by 2
    assert_difference('Expense.count', -2) do
      # delete simulates a DELETE request to destroy_multiple
      delete destroy_multiple_expenses_url, params: { selected_ids: "#{expense1.id},#{expense2.id}" }
    end
    
    # Should redirect to index after deletion
    assert_redirected_to expenses_url
  end
end
