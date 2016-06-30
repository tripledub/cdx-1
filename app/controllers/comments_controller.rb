class CommentsController < ApplicationController
  respond_to :html
  respond_to :json, only: [:index]

  expose(:patient) { find_patient }

  expose(:comments, scope: -> { patient.comments })

  expose(:comment, scope: -> { patient.comments }, attributes: :comment_params)

  before_filter :check_permissions, only: [:new, :create]

  def index
    render json: Presenters::Comments.patient_view(comments.joins(:user).order(set_order_from_params).limit(30).offset(params[:page] || 0))
  end

  def show
  end

  def new
  end

  def create
    comment.patient      = patient
    comment.user         = current_user

    if comment.save_and_audit(current_user, 'New comment added', comment.comment)
      redirect_to patient_path(patient), notice: 'Comment was successfully created.'
    else
      render action: 'new'
    end
  end

  protected

  def find_patient
    @patient = @navigation_context.institution.patients.find(params[:patient_id])
  end

  def comment_params
    params.require(:comment).permit(:commented_on, :description, :comment, :image)
  end

  def check_permissions
    redirect_to(patient_path(patient), error: "You can't add comments to this patient") unless has_access?(patient, UPDATE_PATIENT)
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'asc' : 'desc'
    params[:field] == 'name' ? "users.first_name #{order}, users.last_name" : "comments.commented_on #{order}"
  end
end
