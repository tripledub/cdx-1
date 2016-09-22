CustomTranslation.delete_all
FeedbackMessage.delete_all
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Institution.all.each do |institution|
  s001 = institution.feedback_messages.create!({ category: 'samples_collected', code: 'S001' })
  s001.custom_translations.create!({ lang: 'en', text: 'Samples missing' })

  s002 = institution.feedback_messages.create!({ category: 'samples_collected', code: 'S002' })
  s002.custom_translations.create!({ lang: 'en', text: 'Samples damaged' })
end
