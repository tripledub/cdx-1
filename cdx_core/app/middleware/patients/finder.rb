class Patients::Finder
  attr_reader :filter_query

  def initialize(current_user, navigation_context, params)
    @current_user       = current_user
    @navigation_context = navigation_context
    @params             = params
    set_filter
  end

  protected

  def set_filter
    filter_allowed_patients
    filter_by_navigation_context
    filter_by_name
    filter_by_entity
    filter_by_birth_date
    filter_by_address
  end

  def filter_allowed_patients
    @filter_query = Policy.authorize(Policy::Actions::READ_PATIENT, Patient.where(is_phantom: false).where(institution: @navigation_context.institution), @current_user)
  end

  def filter_by_navigation_context
    @filter_query = filter_query.within(@navigation_context.entity, @navigation_context.exclude_subsites)
  end

  def filter_by_name
    @filter_query = filter_query.where("name LIKE concat('%', ?, '%')", @params[:name]) unless @params[:name].blank?
  end

  def filter_by_entity
    @filter_query = filter_query.where("entity_id LIKE concat('%', ?, '%')", @params[:entity_id]) unless @params[:entity_id].blank?
  end

  def filter_by_address
    return unless @params[:address].present?

    @filter_query = filter_query.joins(:addresses)
      .where("addresses.address LIKE concat('%', ?, '%') or addresses.zip_code LIKE concat('%', ?, '%') or addresses.city LIKE concat('%', ?, '%') or addresses.state LIKE concat('%', ?, '%')", @params[:address], @params[:address], @params[:address], @params[:address]).distinct
  end

  def filter_by_birth_date
    return unless @params[:since_dob].present?
    since_day = start_date + ' 00:00'
    until_day = end_date + ' 23:59'

    @filter_query = filter_query.where('patients.birth_date_on' => since_day..until_day)
  end

  def start_date
    @params[:since_dob]
  end

  def end_date
    @params[:until_dob].present? ? @params[:until_dob] : Date.today.strftime("%Y-%m-%d")
  end
end
