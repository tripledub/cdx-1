module FeedbackMessages
  class Presenter
    class << self
      def reject_reasons(institution, language)
        {
          samples_collected: get_messages(institution, 'samples_collected', language),
          approval: get_messages(institution, 'approval', language)
        }
      end

      protected

      def get_messages(institution, category, language)
        feedback_messages = institution.feedback_messages.where(category: category)
        return [] unless feedback_messages

        feedback_messages.map do |feedback_message|
          get_translated_text(feedback_message, language)
        end
      end

      def get_translated_text(feedback_message, language)
        custom_translation = feedback_message.custom_translations.where(lang: language).first

        {
          id:   custom_translation.id,
          text: "#{custom_translation.text} (#{feedback_message.code})"
        }
      end
    end
  end
end
