class Course < ActiveRecord::Base

  after_create :init
  has_many :grades
  has_many :selections
  has_many :users, through: :selections
  belongs_to :teacher, class_name: "User"

  validates :name, :course_type, :course_time, :course_week,
            :class_room, :credit, :teaching_type, :exam_type, presence: true, length: {maximum: 50}
  validates :student_num, numericality: {greater_than_or_equal_to: 0}
  validates :limit_num, numericality: {greater_than_or_equal_to: 0}

  def init
    if self.student_num==nil 
      self.student_num=0
    end
    if self.limit_num==nil 
      self.limit_num=0
    end
  end

end
