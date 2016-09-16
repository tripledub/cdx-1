class TestBatchRow extends React.Component{
  render() {
    return(
      <tr>
        <td>{this.props.patientResult.testType}</td>
        <td>{this.props.patientResult.sampleId}</td>
        <td>{this.props.patientResult.orderedBy}</td>
        <td>{this.props.patientResult.createdAt}</td>
        <td>{this.props.patientResult.requestedBy}</td>
        <td>{this.props.patientResult.dueDate}</td>
        <td>{this.props.patientResult.status}</td>
        <td>{this.props.patientResult.comment}</td>
        <td>{this.props.patientResult.options}}</td>
      </tr>
    )
  }
}

TestBatchList.propTypes = {
  patientResult: React.PropTypes.object,
};
