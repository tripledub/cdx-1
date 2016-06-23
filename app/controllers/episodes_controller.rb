class EpisodesController < ApplicationController
  before_filter :find_patient
  before_filter :find_episode, only: [:edit, :update]
  before_filter :check_access, only: [:new, :create, :edit, :update]

  def create
    @episode = @patient.episodes.new(episode_params)
    if @episode.save
      redirect_to patient_path(@patient), notice: 'Episode successfully created.'
    else
      render action: 'new'
    end
  end

  def edit; end

  def new
    @episode = @patient.episodes.new
  end

  def update
    if @episode && @episode.update(episode_params)
      redirect_to patient_path(@patient), notice: 'Episode successfully updated.'
    end
  end

  protected

  def check_access
    redirect_to(
      patient_path(@patient),
      error: "You don't have permisson add an episode for this patient") \
      unless has_access?(@patient, UPDATE_PATIENT)
  end

  def episode_params
    params.require(:episode).permit(
      :diagnosis,
      :hiv_status,
      :drug_resistance,
      :anatomical_site_diagnosis,
      :initial_history,
      :previous_history,
      :outcome
    )
  end

  def find_episode
    @episode = Episode.where(
      id: params[:id],
      patient_id: params[:patient_id],
    ).first
  end

  def find_patient
    @patient = Patient.where(
      id: params[:patient_id],
      institution: @navigation_context.institution
    ).first
  end
end
