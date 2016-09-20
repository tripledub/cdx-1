class TestBatchTable extends React.Component{
  render() {
    return(
      <table className="table testBatchTable" cellPadding="0" cellSpacing="0">
        <thead>
          <tr>
            <th>Type</th>
            <th>Sample Id</th>
            <th>Examined by</th>
            <th></th>
            <th></th>
            <th>Options</th>
          </tr>
        </thead>
        <tbody>
          { this.props.patientResults.map(function(patientResult) {
             return <TestBatchRow key={ patientResult.id } patientResult={ patientResult } />;
          }.bind(this)) }
        </tbody>
      </table>
    );
  }
}

TestBatchTable.propTypes = {
  patientResults: React.PropTypes.array,
};
