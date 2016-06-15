class CommentsController < ApplicationController
  respond_to :html

  before_filter :find_patient

  expose(:comment, scope: -> { @patient.comments })

  def index
  end

  def new
    @comment = @patient.comments.new
  end

  def create
    @comment              = @patient.comments.new(comment_params)
    @comment.user         = current_user
    @comment.commented_on = Extras::Dates::Format.string_to_pattern(params[:comment][:commented_on])

    if @comment.save
      redirect_to patient_path(@patient), notice: 'Comment was successfully created.'
    else
      render action: 'new'
    end
  end

  protected

  def find_patient
    @patient = Patient.where(institution: @navigation_context.institution, id: params[:patient_id]).first
  end

  def comment_params
    params.require(:comment).permit(:commented_on, :description, :comment)
  end
end
