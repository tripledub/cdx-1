var LoadingResults = React.createClass({
  render: function(){
    return (
      <h3 className="centered">
        {this.props.loadingMessage}
      </h3>
    );
  }
});
