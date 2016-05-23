class TestsRun < SitePrism::Section
  class PieChart < SitePrism::Section
    element :total, 'svg .main.total:first-child'
  end

  class SnailPieChart < SitePrism::Section
    element :total, 'svg .main.total:first-child'
  end

  section :snail_pie_chart, SnailPieChart, '[data-react-class="SnailPieChart"]'
  section :pie_chart, PieChart, '[data-react-class="PieChart"]'
end
