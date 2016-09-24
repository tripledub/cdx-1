module FeedbackMessages
  class Finder
    class << self

      def find_current_translation(feedback_message)
        translation = feedback_message.custom_translations.where(lang: I18n.locale).first
        translation.present? ? translation.text : I18n.t('feedback_messages.finder.translation_not_found')
      end

      def find_text_from_patient_result(patient_result)
        return '' unless patient_result.feedback_message_id

        find_current_translation(patient_result.feedback_message)
      end
    end
  end
end
