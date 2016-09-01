class NewCultureResultsPage < CdxPageBase
  set_url "/requested_tests/{id}/culture_result/new"

  def id
    url_matches['id'].to_i
  end
  
  section :table, CdxTable, "table"   
end