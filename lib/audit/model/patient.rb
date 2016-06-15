class Audit::Model::Patient < Audit::Auditor
  def create
    create_log('New patient added')
  end

  def update
    update_log('Patient details have been updated')
  end
end
