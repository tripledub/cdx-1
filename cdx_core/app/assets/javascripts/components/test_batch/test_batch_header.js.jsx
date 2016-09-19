class TestBatchHeader extends React.Component{
  render() {
    return(
      <div className="batch-results col">
        <p className="batch-header">
          { I18n.t('components.test_batch.header') }: { this.props.batchId }
        </p>
        <p className="batch-status col">
          { I18n.t('components.test_batch.status') }: { I18n.t('components.test_batch.' + this.props.status) }
        </p>
      </div>
    );
  }
}

TestBatchHeader.propTypes = {
  batchId: React.PropTypes.string,
  status: React.PropTypes.string,
};
