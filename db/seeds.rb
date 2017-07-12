# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

q1 = Question.create_multiple_choice_question(
              "What is 2+2?",
              [
                Answer.create(answer_text: '4', is_answer: true),
                Answer.create(answer_text: '2'),
                Answer.create(answer_text: '1'),
                Answer.create(answer_text: '8')
              ]
          )
q1.curriculum_reference = 'testing'
q1.max_time = 300

q2 = Question.create_input_question("What is 5+5?", [Answer.create(answer_text: "10")])
q2.curriculum_reference = 'testing'
q2.max_time = 300

q3 = Question.create_input_question("What is 5*5?", [Answer.create(answer_text: "25")])
q3.curriculum_reference = 'testing'
q3.max_time = 300

Test.first_or_create(title: 'Example Test',
            duration: 5.days,
            questions: [q1, q2, q3])

User.where(
  first_name: 'Admin',
  last_name: 'Adminton',
  email: 'admin@example.com',
  postcode: 'S3 7GA').first_or_create(
  password: 'mypassword123',
  password_confirmation: 'mypassword123',
  level_of_education: User.default_education,
  employment_status: User.default_employment,
  diagnosis: User.default_diagnosis,
  admin: true)

Test.first.enrol(User.first)
