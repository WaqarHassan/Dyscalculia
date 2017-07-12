# == Schema Information
#
# Table name: answers
#
#  id                          :integer          not null, primary key
#  answer_text                 :string(255)
#  is_answer                   :boolean
#  input_question_id           :integer
#  multiple_choice_question_id :integer
#
# Indexes
#
#  index_answers_on_input_question_id            (input_question_id)
#  index_answers_on_multiple_choice_question_id  (multiple_choice_question_id)
#

class Answer < ActiveRecord::Base
  belongs_to :input_question
  belongs_to :multiple_choice_question
  validates :answer_text, presence: true
end
