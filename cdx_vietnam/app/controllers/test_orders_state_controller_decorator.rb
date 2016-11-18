# Vietnam specific csv export of patients
class TestOrdersStateController
  def patients
    patients = Patients::Finder.new(current_user, @navigation_context, params).filter_query
    respond_to do |format|
      format.csv do
        csv_file = Patients::ListCsv.new(patients, get_hostname)
        headers['Content-Type']        = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.export
      end
    end
  end
end
