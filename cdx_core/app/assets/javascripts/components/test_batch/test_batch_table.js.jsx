class TestBatchTable extends React.Component{
  render() {
    return(
      <table className="table testBatchTable" cellPadding="0" cellSpacing="0">
        <thead>
          <tr>
            <th>Type</th>
            <th>Sample Id</th>
            <th>Examined by</th>
            <th>Options</th>
          </tr>
        </thead>
        <tbody>
          { this.props.patientResults.map(function(patientResult) {
             return <TestBatchRow key={ patientResult.id } paymentDone={ this.props.paymentDone } rejectReasons={ this.props.rejectReasons } patientResult={ patientResult } updateResultUrl={ this.props.updateResultUrl } />;
          }.bind(this)) }
        </tbody>
      </table>
    );
  }
}

TestBatchTable.propTypes = {
  patientResults: React.PropTypes.array,
  rejectReasons: React.PropTypes.object.isRequired,
  paymentDone: React.PropTypes.bool.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
