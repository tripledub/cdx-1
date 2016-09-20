class TestBatchRow extends React.Component{
  render() {
    return(
      <tr>
        <td>{this.props.patientResult.testType}</td>
        <td>{this.props.patientResult.sampleId}</td>
        <td>{this.props.patientResult.examinedBy}</td>
        <td>{this.props.patientResult.comment}</td>
        <td>{this.props.patientResult.completedAt}</td>
        <td>{this.props.patientResult.createdAt}</td>
        <td><TestResultStatus resultId={ this.props.patientResult.id } currentStatus={ this.props.patientResult.status } updateResultUrl={ this.props.updateResultUrl } /></td>
      </tr>
    )
  }
}

TestBatchRow.propTypes = {
  patientResult: React.PropTypes.object.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
