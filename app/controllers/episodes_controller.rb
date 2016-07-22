class EpisodesController < ApplicationController

  respond_to :json, only: [:index]

  before_filter :find_patient
  before_filter :find_episode, only: [:edit, :update]
  before_filter :check_access, only: [:new, :create, :edit, :update]

  def index
    render json: Presenters::Episodes.patient_episodes(@patient.episodes.where('closed = ?', params['status']).order(created_at: :desc))
  end

  def create
    @episode = @patient.episodes.new(episode_params)
    if @episode.save_and_audit(current_user, I18n.t('episodes.create.new_episode'), @episode)
      redirect_to patient_path(@patient), notice: I18n.t('episodes.create.episode_created')
    else
      render action: 'new'
    end
  end

  def edit; end

  def new
    @episode = @patient.episodes.new
  end

  def update
    if @episode && @episode.update_and_audit( episode_params, current_user, I18n.t('episodes.update.update_episode'))
      redirect_to patient_path(@patient), notice: I18n.t('episodes.update.episode_updated')
    end
  end

  protected

  def check_access
    redirect_to(patient_path(@patient), error: I18n.t('episodes.permission.not_allowed')) unless has_access?(@patient, UPDATE_PATIENT)
  end

  def episode_params
    params.require(:episode).permit(
      :diagnosis,
      :hiv_status,
      :drug_resistance,
      :anatomical_site_diagnosis,
      :initial_history,
      :previous_history,
      :outcome,
      :closed
    )
  end

  def find_episode
    @episode = @patient.episodes.find(params[:id])
  end

  def find_patient
    @patient = Patient.where(
      id: params[:patient_id],
      institution: @navigation_context.institution
    ).first
  end
end
