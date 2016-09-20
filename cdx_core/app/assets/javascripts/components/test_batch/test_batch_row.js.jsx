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
        <td><TestResultStatus currentStatus={ this.props.patientResult.status } /></td>
      </tr>
    )
  }
}

TestBatchRow.propTypes = {
  patientResult: React.PropTypes.object.isRequired,
};
