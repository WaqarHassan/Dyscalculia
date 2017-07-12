class UserController < ApplicationController

  before_filter :authenticate_user!
  layout 'admin', :only => [:index, :search]

  def edit
    @user = current_user
  end

  def show
    @user = User.find(params[:user_id])
    authorize! :manage, @user
    render 'user_overview/show_details', layout: 'admin'
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end

  def index
    authorize! :manage, User.first
    @user = User.new
  end

  def search
    @q_params = params.require(:user).permit(:first_name, :last_name, :email, :date_of_birth, :level_of_education, :diagnosis, :employment_status, :gender)
    @users = User.all
    authorize! :manage, User.first
    @users = @users.where('lower(first_name) = ?', @q_params[:first_name].strip.downcase) if @q_params[:first_name].present?
    @users = @users.where('lower(last_name) = ?', @q_params[:last_name].strip.downcase) if @q_params[:last_name].present?
    @users = @users.where('lower(email) = ?', @q_params[:email].strip.downcase) if @q_params[:email].present?
    @users = @users.where('level_of_education = ?', @q_params[:level_of_education]) if @q_params[:level_of_education].present?
    @selected_gender = @q_params[:gender]
    case @selected_gender
    when "male"
      @users = @users.where(:gender => 0)
    when "female"
      @users = @users.where(:gender => 1)
    when "transgender"
      @users = @users.where(:gender => 2)
    when "prefer_not_to_say"
      @users = @users.where(:gender => 3)
    end

    # case @selected_age
    # when "< 5"
    #   @users = @users.where(:date_of_birth > (Time.now.to_date - 5.years))
    # when "6-10"
    #    @users = @users.where(:date_of_birth > (Time.now.to_date - 10.years) && :date_of_birth <= (Time.now.to_date - 5.years))
    # when "11-17"
    #   @users = @users.where(:date_of_birth > (Time.now.to_date - 18.years) && :date_of_birth <= (Time.now.to_date - 10.years))
    # when "18+"
    #   @users = @users.where(:date_of_birth <= (Time.now.to_date - 18.years))
    # end

    @users = @users.where('employment_status = ?', @q_params[:employment_status]) if @q_params[:employment_status].present?
    @users = @users.where('diagnosis = ?', @q_params[:diagnosis]) if @q_params[:diagnosis].present?

    @selected_first_name = @q_params[:first_name]
    @selected_last_name = @q_params[:last_name]
    # @selected_age = @q_params[:date_of_birth]
    @selected_level_of_education = @q_params[:level_of_education]
    @selected_employment_status = @q_params[:employment_status]
    @selected_diagnosis = @q_params[:diagnosis]


    @status = @q_params[:employment_status] if @q_params[:employment_status].present?
    
    order = params[:order]
    mode = params[:sort_mode]

    @users = @users.to_a
    case mode
    when "asc"
      case order
      when "first_name"
        @users.sort_by! {|r| r.first_name.downcase }
      when "last_name"
        @users.sort_by! {|r| r.last_name.downcase }
      when "email"
        @users.sort_by! {|r| r.email.downcase }
      when "gender"
        @users.sort_by! {|r| r.gender.downcase }
      when "date_of_birth"
        @users.sort_by! {|r| r.date_of_birth }
      when "level_of_education"
        @users.sort_by! {|r| r.level_of_education.downcase }
      when "diagnosis"
        @users.sort_by! {|r| r.diagnosis.downcase }
      when "employment_status"
        @users.sort_by! {|r| r.employment_status.downcase }
      end
    when "desc"
      case order
      when "first_name"
        @users.sort! {|r1,r2| r2.first_name.downcase <=> r1.first_name.downcase }
      when "last_name"
        @users.sort! {|r1,r2| r2.last_name.downcase <=> r1.last_name.downcase }
      when "email"
        @users.sort_by! {|r1,r2| r2.email.downcase <=> r1.email.downcase  }
      when "gender"
        @users.sort! {|r1,r2| r2.gender.downcase <=> r1.gender.downcase }
      when "date_of_birth"
        @users.sort! {|r1,r2| r2.date_of_birth <=> r1.date_of_birth }
      when "level_of_education"
        @users.sort! {|r1,r2| r2.level_of_education.downcase <=> r1.level_of_education.downcase }
      when "diagnosis"
        @users.sort! {|r1,r2| r2.diagnosis.downcase <=> r1.diagnosis.downcase }
      when "employment_status"
        @users.sort! {|r1,r2| r2.employment_status.downcase <=> r1.employment_status.downcase }
      end
    end

    @tests = @users.map{ |u| u.tests }.flatten.uniq

    @test = Test.find(params[:test_id]) if params[:test_id].present?

    @results = @users
    if @test.present?
      a = Struct.new(:first_name, :last_name, :email, :gender, :level_of_education, :date_of_birth, :time_taken, :score, :user_id, :user_test)
      @users = @users.select { |u| u.user_tests.any? { |ut| ut.test.id == @test.id } }
      @results = @users.map do |user|
        user_test = user.user_tests.select {|ut| ut.test.id == @test.id}.first
        a.new(user.first_name, user.last_name, user.email, user.gender, user.level_of_education, user.date_of_birth, user_test.total_time, user_test.correct_answers, user.id, user_test)
      end

      excel = Axlsx::Package.new
      excel.workbook do |sheet|
        styles = sheet.styles
        title = styles.add_style :bg_color => "D8D8D8", :b => true, :sz => 16, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
        header = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
        row = styles.add_style :sz => 12
        sheet.add_worksheet(:name => 'Filtered results per user') do |w|
          w.merge_cells "A1:H1"
          w.add_row ['Filtered Test Results per user of: ' + @test.title], :style => title
          w.add_row ['First Name', 'Last Name', 'email', 'Gender', 'Date of Birth', 'Level of Education', 'Time Taken (Sec)', 'Score'], :style => header
          w.column_widths 16, 16, 30, 16, 10, 30, 16, 8
          @results.each do |r|
            date = r.date_of_birth.strftime('%B %d, %Y')
            time_taken = r.time_taken/1000.0
            w.add_row ["#{r.first_name}", "#{r.last_name}", r.email, r.gender.humanize, date, r.level_of_education.humanize, time_taken, r.score], :style => row
          end
        end
      end
      excel.use_shared_strings = true
      directory_name = 'tmp/spreadsheets/'
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      file_path = directory_name + @test.title.to_s.parameterize('_') + '_' + 'results_per_test' + '_' + Time.now.strftime('%e_%B_%Y_%l:%M_%p') + '.xlsx'

      respond_to do |format|
        format.html
        format.xlsx {
          excel.serialize(file_path)
          send_file(file_path)
        }
      end
    end

    case mode
    when "asc"
      case order
      when "first_name"
        @results.sort_by! {|r| r.first_name.downcase }
      when "last_name"
        @results.sort_by! {|r| r.last_name.downcase }
      when "gender"
        @results.sort_by! {|r| r.gender.downcase }
      when "date_of_birth"
        @results.sort_by! {|r| r.date_of_birth }
      when "level_of_education"
        @results.sort_by! {|r| r.level_of_education.downcase }
      when "time_taken"
        @results.sort_by! {|r| r.time_taken}
      when "score"
        @results.sort_by! {|r| r.score }
      end
    when "desc"
      case order
      when "first_name"
        @results.sort! {|r1,r2| r2.first_name.downcase <=> r1.first_name.downcase }
      when "last_name"
        @results.sort! {|r1,r2| r2.last_name.downcase <=> r1.last_name.downcase }
      when "gender"
        @results.sort! {|r1,r2| r2.gender.downcase <=> r1.gender.downcase }
      when "date_of_birth"
        @results.sort! {|r1,r2| r2.date_of_birth <=> r1.date_of_birth }
      when "level_of_education"
        @results.sort! {|r1,r2| r2.level_of_education.downcase <=> r1.level_of_education.downcase }
      when "time_taken"
        @results.sort! {|r1,r2| r2.time_taken <=> r1.time_taken }
      when "score"
        @results.sort! {|r1,r2| r2.score <=> r1.score }
      end
    end

  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:password, :password_confirmation)
  end
end
