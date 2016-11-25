module FeedbackMessages
  # Groups feedback reasons by category
  class Presenter
    class << self
      def reject_reasons(institution)
        {
          samplesCollected: reject_reasons_category(institution, 'samples_collected'),
          approval: reject_reasons_category(institution, 'approval'),
          labTech: reject_reasons_category(institution, 'lab_tech'),
          finance: reject_reasons_category(institution, 'finance')
        }
      end

      def reject_reasons_category(institution, category)
        feedback_messages = institution.feedback_messages.where(category: category)
        return [] unless feedback_messages

        feedback_messages.map do |feedback_message|
          get_translated_text(feedback_message)
        end
      end

      protected

      def get_translated_text(feedback_message)
        {
          id:   feedback_message.id,
          text: "#{FeedbackMessages::Finder.find_current_translation(feedback_message)} (#{feedback_message.code})"
        }
      end
    end
  end
end
