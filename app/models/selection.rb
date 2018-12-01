class Selection < ActiveRecord::Base
    after_create :init
    belongs_to :course
    belongs_to :user

    validates :points, numericality: {greater_than_or_equal_to: 0}

    def init
      if self.points==nil 
        self.points=0
      end
      if self.fixed==nil
        self.fixed=false
      end
    end
  end