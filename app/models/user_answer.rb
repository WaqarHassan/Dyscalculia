# == Schema Information
#
# Table name: user_answers
#
#  id           :integer          not null, primary key
#  time_taken   :integer          default(0)
#  answer_text  :text(65535)
#  correct      :boolean          default(FALSE)
#  user_test_id :integer
#  question_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :integer          default(0)
#  extra_time   :integer          default(0)
#
# Indexes
#
#  index_user_answers_on_question_id   (question_id)
#  index_user_answers_on_user_test_id  (user_test_id)
#

class UserAnswer < ActiveRecord::Base
  belongs_to :user_test, dependent: :destroy
  belongs_to :question
  delegate :user, :to => :user_test
  enum status: [ :active, :answered, :timed_out, :skipped ]
end
