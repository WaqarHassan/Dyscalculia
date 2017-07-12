# SOMEHOW IT WORKS! DO NOT TOUCH. I DARE YOU, I DOUBLE DARE YOU
# == Schema Information
#
# Table name: tests
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  title      :string(255)
#  test_code  :string(255)
#  duration   :integer
#  live       :boolean          default(FALSE)
#

class Test < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :user_tests
  has_many :users, through: :user_tests
  before_create :generate_test_code
  after_save :add_question_numbers
  validates :title, presence: true
  validate :correct_duration

  def self.days(d)
    return 60 * 60 * 24 * d
  end

  def self.create_test(text)
    t = Test.new(name: text)
    t.test_code = self.generate_test_code
    return t
  end

  def self.dup_test(test)
    t = Test.new(title: test.title, duration: test.duration)
    test.questions.each do |q|
      q1 = q.dup
      q1.questionable = q.questionable.dup
      q.questionable.answers.each do |a|
        a1 = a.dup
        q1.questionable.answers << a1
      end
      q1.picture = q.picture if q.picture.present?
      q1.reading = q.reading if q.reading.present?
      t.questions << q1
    end
    t.test_code = t.generate_test_code
    return t
  end

  def questions_in_order
    self.questions.sort { |a,b| a.question_no <=> b.question_no }
  end

  def get_question_by_number(number)
    return questions_in_order[number-1]
  end

  # Starts at 1
  def insert_question_at(index, question)
    if question.is_valid
      # Questions ordered
      question.question_no = index
      questions_in_order[index-1..-1].each do |q|
        q.question_no += 1
        q.save
      end
      self.questions << question
    end
  end

  def insert_question(question)
    if question.is_valid
      question.question_no = self.questions.count + 1
      self.questions << question
    end
  end

  def delete_question(question)
    number = question.question_no

    if question.destroy
      questions = question.test.questions.where('question_no > ?', number)
      questions.each { |q| q.decrement!(:question_no, 1) }
      return true
    end
    return false
  end

  # Starts at 1
  def update_question_at(index, question)
    if question.is_valid
      current_question = Question.where(:test_id => self.id, :question_no => index).first
      current_question.questionable = question.questionable
      current_question.name = question.name
      current_question.picture = question.picture
      current_question.curriculum_reference = question.curriculum_reference
      current_question.reading = question.reading
      current_question.max_time = question.max_time

      # if user specifies no picture and a picture is on the server remove it
      if current_question.picture.path && !question.picture.path
        current_question.remove_picture!
      end

      # if user specifies no reading and a reading is on the server remove it
      if current_question.reading.path && !question.reading.path
        current_question.remove_reading!
      end

      if current_question.save
        current_question.equations.replace(question.equations)
        current_question.answers.replace(question.answers)
      end
    end
  end

  def enrol(user)
    ut = UserTest.new
    ut.test = self
    ut.user = user
    ut.save
    return ut
  end

  def generate_test_code
    self.test_code = SecureRandom.hex(3)
    return self.test_code
  end

  def has_reading_for_all?
    !questions.any? { |q| !q.reading.path }
  end

  def make_live
    if questions.count > 0
      update_attribute(:live, true)
    end
  end

  private
  def add_question_numbers
    self.questions.each_with_index { |row, i| row.update(:question_no => i + 1)}
  end

  def correct_duration
    errors.add(:base, 'Not a valid duration') unless duration.to_i != 0 && duration >= 1
  end


end
