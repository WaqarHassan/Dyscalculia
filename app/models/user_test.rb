# == Schema Information
#
# Table name: user_tests
#
#  id           :integer          not null, primary key
#  started_at   :datetime
#  deadline_at  :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#  test_id      :integer
#  completed_at :datetime
#
# Indexes
#
#  index_user_tests_on_test_id  (test_id)
#  index_user_tests_on_user_id  (user_id)
#

# A test has many user_answers, the current question they are on will be a user_answer
# that is active, prior answers will be, timed_out, skipped, or answered.

class UserTest < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :test, dependent: :destroy
  has_many :user_answers
  validates :user_id, presence: true
  validates :test_id, presence: true
  validates_uniqueness_of :user_id, scope: :test_id
  after_initialize :check_completed

  MAX_INCORRECT = 5

  def check_completed
    if deadline_at.present? && time_left <= 0
      self.completed_at = deadline_at
      self.save
    end
  end

  def answer_question(text, time)
    ua = user_answers.last
    ua.answer_text = text
    ua.time_taken = time
    # Setting it here, so the ability to override can be added and it is also
    # more efficient than computing each time

    ua.correct = ua.question.check_answer(text)
    ua.answered!
    ua.save
    proceed
  end

  def time_out_question
    ua = user_answers.last
    ua.time_taken = ua.question.max_time * 1000 + ua.extra_time * 1000
    ua.timed_out!
    ua.save
    proceed
  end

  def skip(time)
    ua = user_answers.last
    ua.time_taken = time
    ua.skipped!
    ua.save
    proceed
  end

  def start
    self.started_at = Time.now
    # .strftime("%Y-%m-%d %H:%M:%S")
    self.deadline_at = started_at + test.duration
    save
    proceed
  end

  def started?
    !started_at.nil?
  end

  def completed?
    !completed_at.nil?
  end

  def current_question_no
    user_answers.count
  end

  def current_question
    user_answers.last.question
  end

  def too_many_wrong_in_a_row
    wrong_in_a_row >= MAX_INCORRECT
  end

  def wrong_in_a_row
    # Dont worry about the current question they are answering
    completed_answers = user_answers.reverse_order[1..-1]
    if completed_answers
      completed_answers.take_while{ |a| !a.correct }.count
    else
      0
    end
  end

  def total_time
    user_answers.to_a.sum { |a| a.time_taken }
  end

  def time_left
    deadline_at - Time.zone.now
  end

  def percent_completed
    if !started?
      0
    elsif completed?
      100
    else
      (user_answers.count-1)*100/test.questions.count
    end
  end

  def correct_answers
    user_answers.to_a.count { |a| a.correct }
  end

  # Proceed sets up a user_answer for the next question
  def proceed
    question = Question.find_by_test_id_and_question_no(test.id, current_question_no+1)
    # question is nil when last question has been answered so no more user_answers needed
    if question && !(wrong_in_a_row >= MAX_INCORRECT-1) && UserAnswer.create(:question => question, :user_test => self)
      save
    elsif !completed?
      complete
    end
  end

  def complete
    self.completed_at = Time.now
    # .strftime("%Y-%m-%d %H:%M:%S")
    save
  end

end
