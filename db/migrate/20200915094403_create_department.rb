class CreateDepartment < ActiveRecord::Migration[6.0]
  def change
    create_table :departments do |t|
      t.string :name
      t.belongs_to :agglomeration
    end
  end
end
