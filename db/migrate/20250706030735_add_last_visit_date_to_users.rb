class AddLastVisitDateToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :last_visit_date, :datetime
  end
end
