# == Schema Information
#
# Table name: equations
#
#  id          :integer          not null, primary key
#  text        :string(255)
#  question_id :integer
#
# Indexes
#
#  index_equations_on_question_id  (question_id)
#

class Equation < ActiveRecord::Base
  belongs_to :question
  validates :text, presence: true
end
