var CanvasJsChart = React.createClass({
  componentDidMount() {
    var chart = new CanvasJS.Chart(this.props.chartDiv, this.props.chartData);
    chart.render();
  },

  render: function(){
    return (
      <p>There was an error displaying the graph.</p>
    );
  }
});
