class Presenters::Comments
  class << self
    def patient_view(comments)
      comments.map do |comment|
        {
          id:          comment.uuid,
          commentDate: comment.commented_on.strftime(I18n.t('date.input_format.pattern')),
          commenter:   comment.user.full_name,
          title:       comment.description,
          viewLink:    Rails.application.routes.url_helpers.patient_comment_path(comment.patient, comment)
        }
      end
    end
  end
end
