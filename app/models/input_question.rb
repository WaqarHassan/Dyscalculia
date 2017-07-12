# == Schema Information
#
# Table name: input_questions
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'fuzzystringmatch'

class InputQuestion < ActiveRecord::Base
  has_one :question, as: :questionable
  has_many :answers
  validate :has_an_answers

  # Jaro Winkler distance threshold
  # https://en.wikipedia.org/wiki/Jaro-Winkler_distance
  CORRECT_THRESHOLD = 0.8
  MATCHER = FuzzyStringMatch::JaroWinkler.create(:pure)


  def is_number? string
    true if Float(string) rescue false
  end

  def check_answer(text)
    if is_number? correct_answer
      return false unless is_number? text
      Float(correct_answer).round(1) == Float(text).round(1)
    else
      distances = answers.map { |a| MATCHER.getDistance(a.answer_text, text) }
      distances.select { |d| d >= CORRECT_THRESHOLD }.any?
    end
  end

  def correct_answer
    return answers.to_a.map { |a| a.answer_text }.to_sentence(:last_word_connector => ' or ')
  end

  private
  def has_an_answers
    errors.add(:base, 'An input qustion must have at least one answer') if answers.size == 0
  end

end
