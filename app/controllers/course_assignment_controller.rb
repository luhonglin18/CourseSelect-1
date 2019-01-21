class CourseAssignmentController < ApplicationController
    
    before_action :admin_logged_in, only: [:assign, :refresh, :points_initialization]
    
    def points_initialization
        User.where(admin: false, teacher: false).find_each do |user|
            user.points = 100
            user.save
        end
    end
    
    def assign
        # Before assign courses to students, make sure the remaining # of students for courses
        # are correct.
        refresh()
        
        # First deal with fixed courses.
        Selection.where(fixed: true).find_each do |selection|
            # Add to grade table and remove it from selection table.
            grade = Grade.find_or_create_by(course: selection.course, user: selection.user)
            course = Course.find_by(id: selection.course.id)
            course.student_num = course.student_num + 1
            course.save
            selection.destroy
        end
        # Then deal with remaining selection by points
        # The following codes are discarded because RoR Active Record don't fxxking support
        # ordering with find_each, so I have to write a new 'find_each' to do the shit.
        #Selection.order("points DESC").find_each do |selection|
        #    # Check if there are remaining # of students in the corresponding courses.
        #    course = Course.find_by(id: selection.course.id)
        #    if course.student_num < course.limit_num
        #        # Assign student to course
        #        grade = Grade.find_or_create_by(course: selection.course, user: selection.user)
        #        course.student_num = course.student_num + 1
        #        course.save
        #    #else
        #        # Do nothing, because you have to delete the selection anyway
        #    end
        #    selection.destroy
        #end
        
        # A new ordering find_each to deal with remaining selection by points
        #batch_size = 512
        #ids = Selection.order('points DESC').pluck(:id)
        #ids.each_slice(batch_size) do |chunk|
        #    Selection.find(chunk, :order => "field(id, #{chunk.join(',')})").each do |selection|
        #        course = Course.find_by(id: selection.course.id)
        #        if course.student_num < course.limit_num
        #            grade = Grade.find_or_create_by(course: selection.course, user: selection.user)
        #            course.student_num = course.student_num + 1
        #            course.save
        #        end
        #        selection.destroy
        #    end
        #end
        
        # That doesn't work. This really pissed me off. I got to find something to bypass this.
        # A new way of dealing with points. This may runs a little bit slower.
        while Selection.all.count > 0 do
            # Pop max on points each iteration and deal with it.
            max_points = Selection.maximum("points")
            Selection.where(points: max_points).find_each do |selection|
                course = Course.find_by(id: selection.course.id)
                if course.student_num < course.limit_num or course.limit_num == 0
                    # Assign student to course
                    grade = Grade.find_or_create_by(course: selection.course, user: selection.user)
                    course.student_num = course.student_num + 1
                    course.save
                else
                    student=User.find_by(id: selection.user.id)
                    student.points = student.points + selection.points
                    student.save
                end
                selection.destroy
            end
        end
        
        
        # How stupid I am that I dreamed that the following code would work
        #new_selections = Selection.order(points: :desc)
        #new_selections.find_each do |selection|
        #    # Check if there are remaining # of students in the corresponding courses.
        #    course = Course.find_by(id: selection.course.id)
        #    if course.student_num < course.limit_num
        #        # Assign student to course
        #        grade = Grade.find_or_create_by(course: selection.course, user: selection.user)
        #        course.student_num = course.student_num + 1
        #        course.save
        #    #else
        #        # Do nothing, because you have to delete the selection anyway
        #    end
        #    selection.destroy
        #end
        
    end
    
    def refresh
        #code to count remaining number of students of each course
        hash_by_course = Grade.group(:course).count
        Course.find_each do |course|
            # Code to update student_num
            course.student_num = (hash_by_course[course] == nil) ? 0 : hash_by_course[course]
            course.save
        end
    end
    
    private

    # Confirms a admin logged-in user.
    def admin_logged_in
        unless admin_logged_in?
            redirect_to root_url, flash: {danger: '请登陆'}
        end
    end
    
end
