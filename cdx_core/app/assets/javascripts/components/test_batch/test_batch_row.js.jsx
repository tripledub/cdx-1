class TestBatchRow extends React.Component{
  render() {
    return(
      <tr>
        <td>{this.props.patientResult.testType}</td>
        <td>{this.props.patientResult.sampleId}</td>
        <td>{this.props.patientResult.examinedBy}</td>
        <td><TestResultStatus feedbackMessage={ this.props.patientResult.feedbackMessage } resultId={ this.props.patientResult.id } rejectReasons={ this.props.rejectReasons } editResultUrl={ this.props.patientResult.editUrl } commentValue={ this.props.patientResult.comment } currentStatus={ this.props.patientResult.status } updateResultUrl={ this.props.updateResultUrl } /></td>
      </tr>
    )
  }
}

TestBatchRow.propTypes = {
  patientResult: React.PropTypes.object.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
