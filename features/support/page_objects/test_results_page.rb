class TestResultsPage < CdxPageBase
  set_url '/test_results/{?query*}'

 element :show_filters, :button, 'Show Filters'
   
  section 'form', '#filters-form' do
#    section :type, CdxSelect, "label", text: /Type/i
    section :status, CdxSelect, "label", text: /Status/i
  end
  
  section :table, CdxTable, "table"
end
