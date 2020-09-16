class AddDepartmentToArea < ActiveRecord::Migration[6.0]
  def change
    add_reference :areas, :department, foreign_key: true
  end
end
