# Custom translations
class CustomTranslation < ActiveRecord::Base
  belongs_to :localisable, polymorphic: true, dependent: :destroy
end
