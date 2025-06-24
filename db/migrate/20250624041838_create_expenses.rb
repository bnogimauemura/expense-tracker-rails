class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.date :date
      t.string :description
      t.integer :price
      t.string :category

      t.timestamps
    end
  end
end
