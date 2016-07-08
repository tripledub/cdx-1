class Extras::Charts::HorizontalColumns
  def initialize(options)
    @title   = options.fetch(:title, '')
    @titleY  = options.fetch(:titleY, '')
    @titleY2 = options.fetch(:titleY2, '')
    @columns = options.fetch(:columns, [])
  end

  def render
    {
      axisX:{
        interval: 1,
        gridThickness: 0,
        titleFontSize: 12,
        titleFontFamily: "Arial",
        titleFontColor: "#000",
        labelFontSize: 10,
        labelFontFamily: "Arial",
        labelFontColor: "#000"
      },
      axisY: {
        titleFontSize: 12,
        titleFontFamily: "Arial",
        titleFontColor: "#000",
        labelFontSize: 10,
        labelFontFamily: "Arial",
        labelFontColor: "#000"
      },
      legend:{
        fontSize: 12,
        fontFamily: "Arial",
        fontColor: "#000"
      },
      axisY2: {
        interlacedColor: "rgba(1,77,101,.2)",
        gridColor: "rgba(1,77,101,.1)"
      },
      data: [
        {
          type: "bar",
          name: @titleY2,
          axisYType: "secondary",
          color: "#9dce65",
          dataPoints: @columns
        }
      ]
    }
  end
end
