# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  date_of_birth          :date
#  postcode               :string(255)
#  level_of_education     :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  admin                  :boolean          default(FALSE)
#  diagnosis              :string(255)      default("0")
#  gender                 :integer          default(0)
#  employment_status      :string(255)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  has_many :user_tests
  has_many :tests, through: :user_tests
  enum gender: [:male, :female, :transgender, :prefer_not_to_say]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_format_of :first_name, with: /^[[\s][-a-zA-Z]]*$/, :multiline => true
  validates_format_of :last_name, with: /^[-a-zA-Z]*$/, :multiline => true
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :diagnosis
  validate :education_and_employment_over_eighteen
  validate :dob_cannot_be_in_the_past
  validates_format_of :postcode, with: /^\s*((GIR\s*0AA)|((([A-PR-UWYZ][0-9]{1,2})|(([A-PR-UWYZ][A-HK-Y][0-9]{1,2})|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY]))))\s*[0-9][ABD-HJLNP-UW-Z]{2}))\s*$/i, multiline: true

  def tests
    super().where(live: true)
  end

  def self.employment_statuses
    ["Employed", "Self employed", "Unemployed", "In education/training", "Prefer not to say"]
  end

  def self.diagnosis
   ["None", "Dyscalculia", "Dyslexia", "Dyspraxia", "Attention Deficit (Hyperactivity) Disorder", "Autistic Spectrum Disorder (Including Asperger's Sybdrome)", "Prefer not to say"]
  end

  def self.level_of_educations
    ["None","GCSE or equivalent", "A levels or equivalent","Degree or equivalent","Masters Level Qualification","phD or equivalent", "Prefer not to say"]
  end

  def self.default_diagnosis
    "None"
  end

  def self.default_education
    "None"
  end

  def self.default_employment
    "Unemployed"
  end

  def age
    now = Time.now.utc.to_date
    age = now.year - date_of_birth.year - (date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
    return age
  end

  def user_tests
    # Not sure how to keep this a relation
    super().to_a.select { |ut| ut.test.present? && ut.test.live}
  end

  def dob_cannot_be_in_the_past
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "can't be in the future")
    end
  end

  def  education_and_employment_over_eighteen
    if date_of_birth.present? && Date.today - date_of_birth >= 18.years
       if !level_of_education.present?
         errors.add(:level_of_education, "has to be present")
       end

       if !employment_status?
         errors.add(:employment_status, "has to be present")
       end
     end
   end

end
