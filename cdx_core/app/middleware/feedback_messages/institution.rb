module FeedbackMessages
  # Add default feedback messages to new institutions
  class Institution
    class << self
      def create_default_messages(institution)
        s001 = institution.feedback_messages.create!({ category: 'samples_collected', code: 'S001' })
        s001.custom_translations.create!({ lang: 'en', text: 'Samples missing' })

        s002 = institution.feedback_messages.create!({ category: 'samples_collected', code: 'S002' })
        s002.custom_translations.create!({ lang: 'en', text: 'Samples damaged' })

        ad001 = institution.feedback_messages.create!({ category: 'approval', code: 'AD0001' })
        ad001.custom_translations.create!({ lang: 'en', text: 'Approval denied' })

        tr001 = institution.feedback_messages.create!({ category: 'lab_tech', code: 'TR0001' })
        tr001.custom_translations.create!({ lang: 'en', text: 'Missing sample' })

        tr002 = institution.feedback_messages.create!({ category: 'lab_tech', code: 'TR0002' })
        tr002.custom_translations.create!({ lang: 'en', text: 'Test aborted' })

        tr003 = institution.feedback_messages.create!({ category: 'lab_tech', code: 'TR0003' })
        tr003.custom_translations.create!({ lang: 'en', text: 'Results unsafe' })
      end
    end
  end
end
