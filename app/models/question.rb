# == Schema Information
#
# Table name: questions
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  questionable_id      :integer
#  questionable_type    :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  test_id              :integer
#  question_no          :integer
#  picture              :string(255)
#  curriculum_reference :string(255)
#  reading              :string(255)
#  max_time             :integer
#
# Indexes
#
#  index_questions_on_name                                   (name)
#  index_questions_on_questionable_type_and_questionable_id  (questionable_type,questionable_id)
#  index_questions_on_test_id                                (test_id)
#

class Question < ActiveRecord::Base
  belongs_to :questionable, polymorphic: true, dependent: :destroy
  belongs_to :test
  has_many :equations
  validates :curriculum_reference, presence: true
  validates :name, presence: true
  validate :enough_time
  validate :has_type

  mount_uploader :picture, QuestionPictureUploader
  mount_uploader :reading, QuestionReadingUploader

  # Could simplify with code block but would probably be less
  # readable
  def self.create_multiple_choice_question(text, answers)
    q = Question.new(name: text)
    mcq = MultipleChoiceQuestion.new
    mcq.answers = answers
    q.questionable = mcq
    return q
  end

  def self.create_input_question(text, answers)
    answers.map { |a| a.is_answer = nil }
    q = Question.new(name: text)
    iq = InputQuestion.new
    iq.answers = answers
    q.questionable = iq
    return q
  end

  # Use the child's implementation
  def check_answer(text)
    return questionable.check_answer(text)
  end

  def correct_answer
    return questionable.correct_answer
  end

  def answers
    return questionable.answers
  end

  # Can't call it valid? for some reason
  def is_valid
    if questionable
      return valid? && questionable.valid?
    else
      return valid?
    end
  end

  def error_messages
    if questionable
      return errors.full_messages + questionable.errors.full_messages
    else
      return errors.full_messages
    end
  end

  def type
    return questionable_type
  end

  def enough_time
    errors.add(:base, 'Max time allocated must be at least 20 seconds') unless max_time >= 20.seconds
  end

  def has_type
    errors.add(:base, 'Must have a question type') unless questionable
  end

end
