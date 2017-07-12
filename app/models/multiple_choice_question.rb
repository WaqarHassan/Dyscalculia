# == Schema Information
#
# Table name: multiple_choice_questions
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MultipleChoiceQuestion < ActiveRecord::Base
  has_one :question, as: :questionable
  has_many :answers

  validate :has_enough_answers
  validate :has_an_answer

  def check_answer(text)
    return answers.where(:is_answer => true).to_a.select { |a| a.answer_text == text}.any?
  end

  def correct_answer
    return answers.find_by_is_answer(true).answer_text
  end

  private
  def has_enough_answers
    errors.add(:base, 'A multiple choice question must have at least two choices') if answers.size < 2
  end

  def has_an_answer
    answer_count = 0
    answers.each { |a| answer_count += 1 if a['is_answer'] }
    errors.add(:base, "A multiple choice question must have 1 correct answer assigned") unless answer_count == 1
  end

end
