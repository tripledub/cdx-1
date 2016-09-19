class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <table className="table testBatchTable" cellPadding="0" cellSpacing="0">
          <thead>
            <tr>
              <th colSpan="7">{ I18n.t('components.test_batch.header') } - { I18n.t('components.test_batch.status') }: { I18n.t('components.test_batch.' + this.props.testBatch.status) }</th>
            </tr>
          </thead>
          <tbody>
            { this.props.testBatch.patientResults.map(function(patientResult) {
               return <TestBatchRow key={ patientResult.id } patientResult={ patientResult } />;
            }.bind(this)) }
          </tbody>
        </table>
      </div>
    );
  }
}

TestBatchList.propTypes = {
  testBatch: React.PropTypes.object,
};
