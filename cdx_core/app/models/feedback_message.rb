class FeedbackMessage < ActiveRecord::Base
  belongs_to :institution
  has_many :patient_results
  has_many :encounters
  has_many :custom_translations, dependent: :destroy, :as => :localisable
end
