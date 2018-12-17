class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    #Contemporily close the open option.
    @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 4)
    #tmp=[]
    #current_user.courses.each do |course|
    #  tmp<<course.id;
    #end
    #@courses = Course.where.not(id:tmp).paginate(page: params[:page], per_page: 10)
    @course = @courses-current_user.courses
    tmp=[]
    @courses.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
  end
  
  def credit
    @courses=current_user.courses
    tmp=[]
    @credits=0
    @courses.each do |course|
      @credits+=course.credit.to_i
      if course.course_type =='公共必修课'
        tmp<<course
      end
    end
    @credits/=20
    @courses=tmp
  end
  def percourse
     @courses=current_user.courses
  end

  def select
    @course=Course.find_by_id(params[:id])
    if @course.limit_num!=0 and @course.student_num>=@course.limit_num
      flash={:suceess => "选择课程: #{@course.name} 失败，人数已满"}
    else
      if current_user.courses.include?@course
         flash={:warning => "已经选择该课程"}
      else 
        @flag=0
        current_user.courses.each do |f|
 		      if f.course_time==@course.course_time
 		         @flag=1
 		         @tmp=f.name
 		      end
 		    end
 		    if @flag==1
 		       flash={:warning => "#{@tmp}与选择课程冲突"}
 		    else
          current_user.courses<<@course
          @course.student_num=@course.student_num+1;
          @course.save
          flash={:suceess => "成功选择课程: #{@course.name}"}
        end
      end
    end
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.student_num=@course.student_num-1;
    @course.save
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 4) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 4) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
