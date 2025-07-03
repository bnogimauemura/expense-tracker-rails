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
    log_in_as(users(:one))
    assert_difference("Expense.count") do
      post expenses_url, params: {
        expense: {
          date: Date.current,
          description: "Test expense",
          price: 1000,
          category: "Food & Dining",
          user_id: users(:one).id
        }
      }
    end
    assert_redirected_to expenses_url
  end

  # Test 3: Should not create expense with invalid data
  test "should not create expense with invalid data" do
    log_in_as(users(:one))
    assert_no_difference("Expense.count") do
      post expenses_url, params: {
        expense: {
          date: nil,  # Invalid: missing date
          description: "",  # Invalid: empty description
          price: nil,  # Invalid: missing price
          category: "",
          user_id: users(:one).id
        }
      }
    end
    assert_response :success
  end

  # Test 4: Should be able to delete multiple expenses
  test "should destroy multiple expenses" do
    log_in_as(users(:one))
    # First create expenses to delete
    expense1 = Expense.create!(
      date: Date.current,
      description: "Expense 1 to delete",
      price: 1000,
      category: "Food & Dining",
      user: users(:one)
    )

    expense2 = Expense.create!(
      date: Date.current,
      description: "Expense 2 to delete",
      price: 2000,
      category: "Transportation",
      user: users(:one)
    )

    assert_difference("Expense.count", -2) do
      delete destroy_multiple_expenses_url, params: { selected_ids: "#{expense1.id},#{expense2.id}" }
    end
    assert_redirected_to expenses_url
  end
end
