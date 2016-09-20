class TestResultStatus extends React.Component{
  render() {
    return(
      { this.props.currentStatus == 'in_progress'}
    )
  }
}

TestResultStatus.propTypes = {
  currentStatus: React.PropTypes.string.isRequired,
};
