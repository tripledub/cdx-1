module Comments
  class Presenter
    class << self
      def patient_view(comments)
        comment_data = {}
        comment_data['rows'] = fetch_rows(comments)
        comment_data['pages'] = {
          totalPages: comments.total_pages,
          currentPage: comments.current_page,
          firstPage: comments.first_page?,
          lastPage: comments.last_page?,
          prevPage: comments.prev_page,
          nextPage: comments.next_page
        }
        comment_data
      end

      protected

      def fetch_rows(comments)
        comments.map do |comment|
          {
            id:          comment.uuid,
            commentDate: I18n.l(comment.created_at, format: :short),
            commenter:   comment.user.full_name,
            title:       comment.description,
            viewLink:    Rails.application.routes.url_helpers.patient_comment_path(comment.patient, comment)
          }
        end
      end
    end
  end
end
