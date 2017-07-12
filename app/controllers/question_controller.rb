class QuestionController < ApplicationController
  before_action :setup_question, only: [:update, :edit, :show, :submit_response, :skip_question, :destroy]
  before_action :create_question_object, only: [:create, :update]
  after_action :set_validation_errors, only: [:create, :update]

  layout 'admin', :only => [:update, :edit, :new, :create, :preview]

  def check_live(test)
    redirect_to admin_overview_path, :notice => 'Cannot edit a live test' if test.live
  end

  def destroy
    authorize! :manage, @current_test
    check_live(@current_test)
    if @current_test.delete_question(@question)
      redirect_to edit_test_path @test_code
    else
      redirect_to @test_code, @question_no
    end
  end

  def update
    authorize! :manage, @current_test
    authorize! :manage, @question
    check_live(@current_test)
    @current_test.update_question_at(@question_no, @updated_question)
    @validation_errors = @updated_question.error_messages
    render :edit
  end

  def create
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    check_live(@current_test)
    authorize! :manage, @current_test
    authorize! :manage, @question
    if @current_test.insert_question(@updated_question)
      redirect_to edit_question_path(@test_code, @updated_question.question_no)
    else
      @validation_errors = @updated_question.error_messages
      @question_no = @current_test.questions.count + 1
      render :new
    end
  end

  def edit
    authorize! :manage, @current_test
    check_live(@current_test)
    @curriculum_reference = @question.curriculum_reference
    @max_time = @question.max_time
    @question_type = @question.type
    @question_picture = @question.picture.url
    @question_reading = @question.reading.url

    if @question.questionable
      @question_type = @question.type
      @answers = @question.answers
    end
  end

  def show_picture
    #render picture if name is correct
    question = Question.find(params[:question_id])
    if question.picture.file.original_filename == "#{params[:name]}.#{params[:format]}"
      send_file question.picture.url
    else
      render_404
    end
  end

  def show_reading
    #render reading if name is correct
    question = Question.find(params[:question_id])
    if question.reading.file.original_filename == "#{params[:name]}.#{params[:format]}"
      send_file question.reading.url
    else
      render_404
    end
  end

  def new
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    authorize! :manage, @current_test
    check_live(@current_test)
    @question_no = @current_test.questions.count + 1
  end

  def show
    @user_test = UserTest.where(test_id: @current_test.id, user_id: current_user).first
    if @user_test.started?
      if @user_test.completed?
        redirect_to(completed_test_path(@test_code))
      elsif @user_test.too_many_wrong_in_a_row
        redirect_to(completed_test_path(@test_code), notice: 'Test ended due to too many incorrect answers in a row.')
      elsif @question_no != @user_test.current_question_no
        redirect_to(question_path(@test_code, @user_test.current_question_no))
      else
        @answers = @question.answers
        @question_type = @question.type
        @question_picture = @question.picture.url
        @has_picture = !@question_picture.nil?
        @question_reading = @question.reading.url
        @has_reading = !@question_reading.nil?
        @time_taken = @user_test.user_answers.last.time_taken
      end
    else
      redirect_to('nsjkn')
    end
  end

  def submit_response
    # Change to take the question as a param
    @user_test = UserTest.where(test_id: @current_test.id, user_id: current_user).first
    if params[:skip]
      @user_test.skip(params[:time_taken])
    else
      @user_test.answer_question(params[:answer], params[:time_taken])
    end
    proceed
  end

  def submit_time
    # TODO: Need to add some anti-cheat stuff here
    current_test = Test.find_by_test_code(params[:test_code])
    user_test = UserTest.where(test_id: current_test.id, user_id: current_user.id).first
    question = current_test.questions.find_by_question_no(params[:question_no])
    user_answer = UserAnswer.find_by_user_test_id_and_question_id(user_test, question)
    user_answer.update_attribute(:time_taken, params[:time].to_i)
    max_time = user_answer.question.max_time

    time_left = max_time*1000 - params[:time].to_i + user_answer.extra_time.to_i*1000

    user_test.time_out_question if time_left <= 0

    respond_to do |format|
      format.json{ render json: {:time_left => time_left}.to_json }
    end
  end

  def extend_time
    current_test = Test.find_by_test_code(params[:test_code])
    user_test = UserTest.where(test_id: current_test.id, user_id: current_user.id).first
    question = current_test.questions.find_by_question_no(params[:question_no])
    user_answer = UserAnswer.find_by_user_test_id_and_question_id(user_test, question)
    user_answer.update_attribute(:extra_time, user_answer.extra_time.to_i + 20.seconds)

    respond_to do |format|
      format.json{ render json: {:extra_time => user_answer}.to_json }
    end
  end

  def preview
    @test_code = params[:test_code]
    @current_test = Test.find_by_test_code(@test_code)
    @question = Question.find(params[:question_id])
    @answers = @question.answers
    @question_type = @question.type
    @question_picture = @question.picture.url
    @has_picture = !@question_picture.nil?
    @question_reading = @question.reading.url
    @has_reading = !@question_reading.nil?
  end

  private

    def proceed
      if @is_last_question
        redirect_to test_path @test_code
      else
        redirect_to question_path(@test_code, @question_no + 1)
      end
    end

    def create_question_object
      @question_params = params.require(:question).permit(
            :question_type,
            :curriculum_reference,
            :question_picture,
            :question_reading,
            :picture_cache,
            :reading_cache,
            :question_text,
            :max_time,
            :equations => [],
            :answers => [:answer_text, :is_answer])

      @question_params['answers'] = @question_params['answers'] ? @question_params['answers'].values : []
      @question_params['equations'] ||= []

      if @question_params[:question_type] == 'MultipleChoiceQuestion'
        @updated_question = Question.create_multiple_choice_question(
                      @question_params[:question_text],
                      #combines the two arrays to match the structure for the database
                      @question_params[:answers].map do |a|
                        Answer.new(:answer_text => a[:answer_text], :is_answer => a[:is_answer] == 'true')
                      end
                  )

      elsif @question_params[:question_type] == 'InputQuestion'
        @updated_question = Question.create_input_question(
                    @question_params[:question_text],
                    @question_params[:answers].map { |a| Answer.new(:answer_text => a[:answer_text]) }
                  )

      else
        @updated_question = Question.new
        @updated_question.name = @question_params[:question_text]
      end

      # If user uploads picture use that
      if @question_params[:question_picture]
        @updated_question.picture = @question_params[:question_picture]
      # If there's a cached one use that
      elsif @question_params[:picture_cache]
        # If it's blank then it came from the server
        if @question_params[:picture_cache] == ''
          @updated_question.picture = @question.picture
        else
          # Otherwise get the cached image
          File.open("public/#{QuestionPictureUploader.cache_dir}/#{@question_params[:picture_cache]}") do |p|
            @updated_question.picture = p
          end
        end
      # Otherwise there's no image
      else
        @updated_question.picture = nil
      end

      # If user uploads picture use that
      if @question_params[:question_reading]
        @updated_question.reading = @question_params[:question_reading]
      # If there's a cached one use that
      elsif @question_params[:reading_cache]
        # If it's blank then it came from the server
        if @question_params[:reading_cache] == ''
          @updated_question.reading = @question.reading
        else
          # Otherwise get the cached image
          File.open("public/#{QuestionReadingUploader.cache_dir}/#{@question_params[:reading_cache]}") do |p|
            @updated_question.reading = p
          end
        end
      # Otherwise there's no reading
      else
        @updated_question.reading = nil
      end

      @updated_question.curriculum_reference = @question_params[:curriculum_reference]
      @updated_question.max_time = @question_params[:max_time] || 0
      @updated_question.equations = @question_params[:equations].map { |e| Equation.new text: e }
      # View variables
      @question_picture = @updated_question.picture.url
      @question_reading = @updated_question.reading.url
      @question_text = @updated_question.name
      @curriculum_reference = @updated_question.curriculum_reference
      @max_time = @updated_question.max_time
      @picture_cache = @updated_question.picture_cache
      @reading_cache = @updated_question.reading_cache
      @equations = @updated_question.equations

      if @updated_question.questionable
        @question_type = @updated_question.type
        @answers = @updated_question.answers
      end

    end

    # Sets up useful variables for a question and the corresponding test
    def setup_question
      @test_code = params[:test_code]
      @current_test = Test.find_by_test_code(@test_code)

      # Give user a 404 if can't find the test
      if @current_test.nil?
        render_404
        return
      end

      @question_no = params[:question_no].to_i

      @is_first_question = @question_no == 1
      @is_last_question = @question_no == @current_test.questions.count

      @question = Question.where(:question_no => @question_no, :test_id => @current_test.id).first

      # Give user a 404 if can't find the question
      if @question.nil?
        render_404
        return
      end

      @question_text = @question.name
      @equations = @question.equations
    end

    def set_validation_errors
      @validation_errors = @updated_question.error_messages
    end


end
