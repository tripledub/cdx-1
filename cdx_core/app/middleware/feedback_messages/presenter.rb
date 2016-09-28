module FeedbackMessages
  # Groups feedback reasons by category
  class Presenter
    class << self
      def reject_reasons(institution)
        {
          samplesCollected: get_messages(institution, 'samples_collected'),
          approval: get_messages(institution, 'approval'),
          labTech: get_messages(institution, 'lab_tech')
        }
      end

      protected

      def get_messages(institution, category)
        feedback_messages = institution.feedback_messages.where(category: category)
        return [] unless feedback_messages

        feedback_messages.map do |feedback_message|
          get_translated_text(feedback_message)
        end
      end

      def get_translated_text(feedback_message)
        {
          id:   feedback_message.id,
          text: "#{FeedbackMessages::Finder.find_current_translation(feedback_message)} (#{feedback_message.code})"
        }
      end
    end
  end
end
