class Extras::Charts::VerticalColumns
  def initialize(options)
    @title   = options.fetch(:title, '')
    @titleY  = options.fetch(:titleY, '')
    @titleY2 = options.fetch(:titleY2, '')
    @columns = options.fetch(:columns, [])
  end

  def render
    {
      theme: "theme3",
      animationEnabled: true,
      title:   { text: @title, fontSize: 30 },
      toolTip: { shared: true },
      axisY:   {
        title: @titleY,
        titleFontSize: 12,
        titleFontFamily: "Arial",
        titleFontColor: "#000",
        labelFontSize: 10,
        labelFontFamily: "Arial",
        labelFontColor: "#000"
      },
      axisY2:  {
        title: @titleY2,
        titleFontSize: 12,
        titleFontFamily: "Arial",
        titleFontColor: "#000",
        labelFontSize: 10,
        labelFontFamily: "Arial",
        labelFontColor: "#000"
      },
      data:    @columns,
      legend: {
        cursor: "pointer",
        fontSize: 10
      },
    }
  end
end
