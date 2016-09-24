class TestBatchHeader extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = {
      testOrderStatus: props.testOrderStatus,
      testBatchStatus: props.testBatchStatus,
    }
  }

  render() {
    return(
      <div className="batch-results col">
        <p className="test-order-status col">
          { I18n.t('components.test_batch.test_order_header') }: { I18n.t('components.test_order.' + this.state.testOrderStatus) }
        </p>
        <p className="batch-header">
          { I18n.t('components.test_batch.header') }: { this.props.batchId } - { I18n.t('components.test_batch.status') }: { I18n.t('components.test_batch.' + this.state.testBatchStatus) }
        </p>

        <p className="batch-payment col">
          { I18n.t('components.test_batch.payment') }: { I18n.t('components.test_batch.' + this.props.paymentDone) }
        </p>
      </div>
    );
  }
}

TestBatchHeader.propTypes = {
  batchId: React.PropTypes.string.isRequired,
  testBatchStatus: React.PropTypes.string.isRequired,
  testOrderStatus: React.PropTypes.string.isRequired,
  paymentDone: React.PropTypes.bool.isRequired,
};
