class Selection < ActiveRecord::Base
    after_initialize :init
    belongs_to :course
    belongs_to :user

    validates :points, numericality: {greater_than_or_equal_to: 0}

    def init
      self.points ||= 0
      self.fixed ||= false
    end
  end