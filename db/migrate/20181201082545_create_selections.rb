class CreateSelections < ActiveRecord::Migration
    def change
      create_table :selections do |t|
        t.belongs_to :course, index: true
        t.belongs_to :user, index: true
        t.integer  :points
        t.boolean  :fixed
        t.timestamps null: false
      end
    end
  end