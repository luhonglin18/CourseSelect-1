class Selection < ActiveRecord::Base
    belongs_to :course
    belongs_to :user

    validates :points, numericality: {greater_than_or_equal_to: 0}
  end