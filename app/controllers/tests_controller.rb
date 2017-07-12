class TestsController < ApplicationController

  layout 'admin', :only => [:index, :edit, :preview, :show_details, :edit_details, :new]


  def check_live(test)
    redirect_to admin_overview_path, :notice => 'Cannot edit a live test' if test.live
  end

  def edit
    @test_code = params[:test_code]
    test = Test.where(test_code: @test_code).first
    authorize! :manage, test
    @test = Test.where(test_code: @test_code).first
    check_live(@test)
    @questions = @test.questions.order(:question_no).paginate(:page => params[:page], :per_page => 5)
  end

  def update
    @updated_test = Test.find(params[:test_id])
    check_live(@updated_test)
    @updated_test.assign_attributes(test_params)
    @updated_test.duration = test_params[:duration].to_i.days.to_i
    if @updated_test.save
      redirect_to edit_test_path(@updated_test.test_code), notice: 'Test has been updated'
    else
      flash.now[:alert] = "Failed to update test"
      redirect_to edit_test_path(@updated_test.test_code)
    end
  end

  def preview
    @test_code = params[:test_code]
    test = Test.where(test_code: @test_code).first
    @title = test.title
    @questions = test.questions.order(:question_no).paginate(:page => params[:page], :per_page => 5)
  end


  def show
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    @user_test = UserTest.where(test_id: @current_test.id, user_id: current_user).first

    if @user_test.started?
      if @user_test.completed?
        redirect_to(completed_test_path(@test_code))
      else
        redirect_to(question_path(@test_code, @user_test.current_question_no))
      end
    end

    test = Test.where(test_code: @test_code).first
    @title = test.title
    @question_count = test.questions.count
    @question_duration_days = test.duration/24/60/60
  end

  def start
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    @user_test = UserTest.where(test_id: @current_test.id, user_id: current_user).first
    @user_test.start
    redirect_to question_path(@test_code, @user_test.current_question_no)
  end

  def enrol
    @test = Test.new
  end

  def process_enrol
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    if @current_test.nil?
      @errors = ['This is not a valid test code. Please enter a valid test code']
    else
      @user_test = @current_test.enrol(current_user)
      if @user_test.valid?
        return redirect_to(tests_path, notice: "Succussfully enrolled on #{@current_test.title}")
      else
        @errors = @user_test.errors.full_messages
      end
    end
    @test = Test.new
    @test.test_code = @test_code
    render :enrol
  end

  def completed
  end

  def make_live
    test = Test.find_by_test_code(params[:test_code])

    if test.make_live
      redirect_to test_results_path
    else
      redirect_to test_results_path, notice: 'Failed to make test live'
    end
  end

  def new
    @test = Test.new
  end

  def create
    @test = Test.new(test_params)
    @test.duration = test_params[:duration].to_i.days.to_i

    if @test.save
      redirect_to edit_test_path(@test.test_code), notice: 'New test has been created'
    else
      if @test.errors.full_messages.any?
        @validation_errors = @test.errors.full_messages
      else
        flash.now[:alert] = "Failed to save"
      end
      render :new, layout: 'admin'
    end
  end

  def duplicate
    @test_code = params[:test_code]
    test = Test.find_by_test_code(@test_code)
    @dup_test = Test.dup_test(test)
    @dup_test.title = test.title + "_duplicate"
    if @dup_test.save
      redirect_to admin_overview_path, notice: 'Test has been duplicated'
    else
      flash.now[:alert] = "Failed to save"
      @test = @dup_test
      render :new, layout: 'admin'
    end
  end

  def destroy
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    if @current_test.destroy
      redirect_to admin_overview_path, notice: 'Test has been deleted'
    else
      redirect_to admin_overview_path, alert: 'Test could not be deleted'
    end
  end

  def show_details
    @user = User.find(params[:user_id])
    @completed = @user.user_tests.select{|t| t.completed?}
    @current = @user.user_tests.select{|t| !t.completed? && t.started?}
  end

  private
  def test_params
    params.require(:test).permit(:title, :duration)
  end
end
