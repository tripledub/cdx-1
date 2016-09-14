module Concerns::Context
  include Policy::Actions
  def ensure_context
    return if current_user.nil?

    if params[:context].blank? && !request.xhr?
      # if there is no context information force it to be explicit
      # this will trigger a redirect ?context=<institution_or_site_uuid>

      # grab last context stored in user
      default_context = current_user.last_navigation_context

      # if user has no longer access, reset it to anything that make sense
      if default_context.nil? || !NavigationContext.new(current_user, default_context).can_read?
        some_institution_uuid = check_access(Institution, READ_INSTITUTION).first.try(:uuid)
        current_user.update_attribute(:last_navigation_context, some_institution_uuid)
        default_context = some_institution_uuid
      end

      redirect_to url_for(params.merge({context: default_context})) if default_context

    elsif !params[:context].blank?
      # if there is an explicit context try to use it.
      @navigation_context = NavigationContext.new(current_user, params[:context])

      if @navigation_context.can_read?
        # store the navigation context as the last one used
        current_user.update_attribute(:last_navigation_context, params[:context])
      elsif request.xhr?
        # if the user has no longer access to this context, reset it for this request
        @navigation_context = nil
      else
        # or redirect the user to an empty context so a new one is set
        redirect_to url_for(params.merge({context: nil}))
      end
    end
  end
end
