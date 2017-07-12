class TestResultsController < ApplicationController
  require 'tempfile'
  layout 'admin', :only => [:index, :show_per_user, :show_per_question, :question_breakdown, :show]
  before_action :toggle_answer, only: [:toggle_user, :toggle_question]
  helper_method :sort_column, :sort_direction

  def index
    tests = Test.all
    test = Test.find_by_test_code(@test_code)
    authorize! :manage, test
    @live_tests = tests.where(:live => true)
    @non_live = tests.where(:live => false)
  end

  def show_per_user
    @test_code = params[:test_code]
    @test = Test.find_by_test_code(@test_code)
    authorize! :manage, @test
    users = @test.users
    user_tests = @test.user_tests.to_a.select{|t| t.completed?}
    @results = user_tests.to_a.map do |ut|
      # Can't do object literals like js so have to do this
      a = Struct.new(:email, :user_id, :first_name, :last_name, :started_at, :completed_at, :time_taken, :score, :started)
      @started = ut.started?
      a.new(ut.user.email, ut.user.id, ut.user.first_name, ut.user.last_name, ut.started_at, ut.completed_at, ut.total_time, ut.correct_answers, ut.started?)
    end

    order = params[:order]
    mode = params[:sort_mode]

    case mode
    when "asc"
      case order
      when "Name"
        @results.sort_by! {|r| r.first_name.downcase }
      when "started_at"
        @results.sort_by! {|r| r.started_at }
      when "completed_at"
        @results.sort_by! {|r| r.completed_at }
      when "time_taken"
        @results.sort_by! {|r| r.time_taken }
      when "score"
        @results.sort_by! {|r| r.score }
      end
    when "desc"
      case order
      when "Name"
        @results.sort! {|r1,r2| r2.first_name.downcase <=> r1.first_name.downcase }
      when "started_at"
        @results.sort! {|r1,r2| r2.started_at <=> r1.started_at }
      when "completed_at"
        @results.sort! {|r1,r2| r2.completed_at <=> r1.completed_at }
      when "time_taken"
        @results.sort! {|r1,r2| r2.time_taken <=> r1.time_taken }
      when "score"
        @results.sort! {|r1,r2| r2.score <=> r1.score }
      end
    end

    excel = Axlsx::Package.new
    excel.workbook do |sheet|
      styles = sheet.styles
      title = styles.add_style :bg_color => "D8D8D8", :b => true, :sz => 16, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
      header = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
      row = styles.add_style :sz => 12
      sheet.add_worksheet(:name => 'Test Results per user') do |w|
        w.merge_cells "A1:F1"
        w.add_row ['Test Results per user of: ' + @test.title], :style => title
        w.add_row ['Name', 'Email', 'Started at', 'Completed at', 'Time Taken (Seconds)', 'Score'], :style => header
        w.column_widths 30, 45, 17, 17, 20, 8
        @results.each do |r|
          started_at = r.started_at.strftime('%e %B %Y %l:%M %p')
          completed_at = r.completed_at.strftime('%e %B %Y %l:%M %p')
          time_taken = r.time_taken/1000.0
          w.add_row ["#{r.first_name} #{r.last_name}", r.email, started_at, completed_at, time_taken, r.score], :style => row
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

  def show_per_question
    @test_code = params[:test_code]
    @test = Test.find_by_test_code(@test_code)
    authorize! :manage, @test
    questions = @test.questions
    @answers = UserAnswer.all.to_a.select{|a| a.user_test.test_id == @test.id}
    @results = questions.map do |q|
      qna = @answers.select {|a| a.question_id == q.id}.sort {|a1,a2| a1.question <=> a2.question }
      a = Struct.new(:question_no, :total_answers, :average_time, :correct_percentage, :most_popular_answer, :question_id, :curriculum_reference)
      num_ans = qna.count
      if qna.count == 0
        count = 1
      else
        count = qna.count.to_f
      end
      total_time = (qna.sum {|q| q.time_taken} / count)
      correct_total = ((qna.sum {|q| q.correct ? 1:0}/num_ans.to_f )* 100).round(2)
      most_popular = qna.select {|q| q.answer_text != nil}.map {|q| q.answer_text}.group_by(&:to_s).values.max_by(&:size).try(:first)
      a.new(q.question_no, num_ans, total_time, correct_total, most_popular, q.id, q.curriculum_reference)
    end

    order = params[:order]
    mode = params[:sort_mode]

    case mode
    when "asc"
      case order
      when "question_no"
        @results.sort_by! {|r| r.question_no }
      when "total_answers"
        @results.sort_by! {|r| r.total_answers }
      when "average_time"
        @results.sort_by! {|r| r.average_time }
      when "correct_percentage"
        @results.sort_by! {|r| r.correct_percentage }
      end
    when "desc"
      case order
      when "question_no"
        @results.sort! {|r1,r2| r2.question_no <=> r1.question_no }
      when "total_answers"
        @results.sort! {|r1,r2| r2.total_answers <=> r1.total_answers }
      when "average_time"
        @results.sort! {|r1,r2| r2.average_time <=> r1.average_time }
      when "correct_percentage"
        @results.sort! {|r1,r2| r2.correct_percentage <=> r1.correct_percentage }
      end
    end


    excel = Axlsx::Package.new
    excel.workbook do |sheet|
      styles = sheet.styles
      title = styles.add_style :bg_color => "D8D8D8", :b => true, :sz => 16, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
      header = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
      row = styles.add_style :sz => 12
      sheet.add_worksheet(:name => 'Test Results per question') do |w|
        w.merge_cells "A1:F1"
        w.add_row ['Test Results per Question of: ' + @test.title], :style => title
        w.add_row ['No.', 'Curriculum Reference', 'Total answers', 'Avg. Time (Seconds)', 'Correct (%)', 'Most popular answer'], :style => header
        w.column_widths 4, 45, 13, 19, 12, 20
        @results.each do |r|
          avg_time = (r.average_time/1000.0).round(2)
          w.add_row [r.question_no, r.curriculum_reference, r.total_answers, avg_time, r.correct_percentage, r.most_popular_answer], :style => row
        end
      end
    end
    excel.use_shared_strings = true
    directory_name = 'tmp/spreadsheets/'
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    file_path = directory_name + @test.title.to_s.parameterize('_') + '_' + 'results_per_question' + '_' + Time.now.strftime('%e_%B_%Y_%l:%M_%p') + '.xlsx'

    respond_to do |format|
      format.html
      format.xlsx {
        excel.serialize(file_path)
        send_file(file_path)
      }
    end
  end

  def question_breakdown
    @question = Question.find(params[:question_id])
    @qna = @question.correct_answer
    ans = UserAnswer.all.to_a.select{|a| a.question_id == @question.id}
    ans.each do |a|
      if !a.answered?
        a.answer_text = a.status.humanize
      end
    end
    @answers = ans.select{|a| a.answered? || a.skipped?}.sort{ |a1, a2| a1.created_at <=> a2.created_at }
    res = Struct.new(:user, :answer, :correct, :correct_bool, :id, :first_name, :last_name, :override)
    @results = @answers.map do |a|
      ut = UserTest.find(a.user_test_id)
      user = User.find(ut.user_id)
      override = a.correct != @question.check_answer(a.answer_text)
      correct = (a.correct ? 'a' : 'b')
      res.new(user.id, a.answer_text, correct, a.correct?, a.id, user.first_name, user.last_name, override)
    end

    order = params[:order]
    mode = params[:sort_mode]

    case mode
    when "asc"
      case order
      when "Name"
        @results.sort_by! {|r| r.first_name.downcase }
      when "correct_bool"
        @results.sort_by! {|r| r.correct}
      when "Edited"
        @results.sort_by! {|r| r.override ? 0 : 1 }
      end
    when "desc"
      case order
      when "Name"
        @results.sort! {|r1,r2| r2.first_name.downcase <=> r1.first_name.downcase }
      when "correct_bool"
        @results.sort! {|r1,r2| r2.correct  <=> r1.correct }
      when "Edited"
        @results.sort_by! {|r| r.override ? 1 : 0 }
      end
    end

  end

  def show

    @user = User.find(params[:user_id])
    @test_code = params[:test_code]
    @test = Test.find_by_test_code(@test_code)
    authorize! :manage, @test
    answers = @user.user_tests.select{ |t| t.test.id == @test.id }[0].user_answers

    @results = answers.sort{|a1,a2| a1.created_at <=> a2.created_at }.to_a.map do |a|
      # Can't do object literals like js so have to do this
      b = Struct.new(
          :question_number, :question, :time_taken, :answer_given,
          :correct_answer, :status, :correct, :question, :id, :override)
          override = a.correct != a.question.check_answer(a.answer_text)
      b.new(a.question.question_no, a.question.name, a.time_taken, a.answer_text, a.question.correct_answer, a.status, a.correct?, a.question, a.id, override)
    end

    @order = params[:order]
    mode = params[:sort_mode]

    case mode
    when "asc"
      case @order
      when "question_number"
        @results.sort_by! {|r| r.question_number }
      when "time_taken"
        @results.sort_by! {|r| r.time_taken }
      when "status"
        @results.sort_by! {|r| r.status }
      when "correct"
        @results.sort_by! {|r| r.correct ? 0 : 1 }
      when "Edited"
        @results.sort_by! {|r| r.override ? 0 : 1 }
      end
    when "desc"
      case @order
      when "question_number"
        @results.sort! {|r1,r2| r2.question_number <=> r1.question_number }
      when "time_taken"
        @results.sort! {|r1,r2| r2.time_taken <=> r1.time_taken }
      when "status"
        @results.sort! {|r1,r2| r2.status <=> r1.status }
      when "correct"
        @results.sort_by! {|r| r.correct ? 1 : 0 }
      when "Edited"
        @results.sort_by! {|r| r.override ? 1 : 0 }
      end
    end

    excel = Axlsx::Package.new
    excel.workbook do |sheet|
      styles = sheet.styles
      title = styles.add_style :bg_color => "D8D8D8", :b => true, :sz => 16, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
      header = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
      row = styles.add_style :sz => 12
      sheet.add_worksheet(:name => 'User Test Results') do |w|
        w.merge_cells "A1:F1"
        w.add_row [@user.first_name + '\'s results for: ' + @test.title], :style => title
        w.add_row ['No.', 'Time Taken (sec)', 'Answer Given', 'Correct Answer', 'Status', 'Result'], :style => header
        w.column_widths 4, 16, 15, 15, 12, 12
        @results.each do |r|
          time = (r.time_taken/1000.0).round(2)
          if r.correct
            ans = 1
          else
            ans = 0
          end
          w.add_row [r.question_number, time, r.answer_given, r.correct_answer, r.status.humanize, ans], :style => row
        end
      end
    end

    excel.use_shared_strings = true
    directory_name = 'tmp/spreadsheets/'
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    file_path = directory_name + @test.title.to_s.parameterize('_') + '_email_' + @user.email.to_s + '_results_' + Time.now.strftime('%e_%B_%Y_%l:%M_%p') + '.xlsx'

    respond_to do |format|
      format.html
      format.xlsx {
        excel.serialize(file_path)
        send_file(file_path)
      }
    end

  end

  def toggle_answer
    @answer = UserAnswer.find(params[:user_answer_id])
    id = @answer.id
    @answer.correct = !@answer.correct
  end

  def toggle_user
    if @answer.save
       redirect_to user_result_path(params[:test_code], params[:user_id]), notice: 'Answer has been updated'
    else
       flash.now[:alert] = "Failed to update test"
       redirect_to user_result_path(params[:test_code], params[:user_id])
    end
  end

  def toggle_question
    if @answer.save
       redirect_to question_breakdown_path(params[:test_code], @answer.question_id), notice: 'Answer has been updated'
    else
       flash.now[:alert] = "Failed to update test"
       redirect_to question_breakdown_path(params[:test_code], @answer.question_id)
    end
  end
end
