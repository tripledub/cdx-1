# Comments controller
class CommentsController < ApplicationController
  respond_to :html
  respond_to :json, only: [:index]

  before_filter :find_patient
  before_filter :check_permissions, only: [:new, :create]
  before_filter :find_comment, only: [:show]

  def index
    page = params[:page] || 1
    comments = @patient.comments.joins(:user).order(set_order_from_params).page(page).per(10)
    render json: Comments::Presenter.patient_view(comments)
  end

  def new
    @comment              = @patient.comments.new
    @comment.commented_on = Date.today
  end

  def create
    @comment              = @patient.comments.new(comment_params)
    @comment.user         = current_user

    if @comment.save_and_audit('t{comments.create.audit_comment}', @comment.comment)
      redirect_to patient_path(@patient), notice: I18n.t('comments.create.comment_ok')
    else
      render action: 'new'
    end
  end

  def show
  end

  protected

  def find_patient
    @patient = Patient.where(institution: @navigation_context.institution, id: params[:patient_id]).first
  end

  def find_comment
    @comment = @patient.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:commented_on, :description, :comment, :image)
  end

  def check_permissions
    redirect_to(patient_path(@patient), error: I18n.t('comments.permissions.deny')) unless has_access?(@patient, UPDATE_PATIENT)
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'asc' : 'desc'
    case params[:field].to_s
    when 'name'
      "users.first_name #{order}, users.last_name"
    when 'description'
      "comments.description #{order}"
    else
      "comments.created_at #{order}"
    end
  end
end
