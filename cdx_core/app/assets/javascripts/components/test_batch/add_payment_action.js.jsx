class AddPaymentAction extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = {
      currentStatus: props.currentStatus,
      commentValue: props.commentValue,
    }
  }

  updateResultStatus(status, comment) {
    this.setState({ currentStatus: status, commentValue: comment })
  }

  render(){
    const approvePayment = {
      actionStatus: 'financed',
      actionStyles: 'btn-danger side-link',
      actionLabel: I18n.t('components.test_result_status.approve_payment.action_label'),
      rejectLabel: I18n.t('components.test_result_status.approve_payment.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.approve_payment.reject_header'),
      rejectReasons: this.props.rejectReasons['labTech'],
      resultId: this.props.resultId,
      updateTestOrderUrl: this.props.encounterRoutes['updateTestOrderUrl'],
      commentValue: this.state.commentValue,
    };

    return(
      <TestOrderActions actionInfo={ approvePayment } updateResultStatus={ this.updateResultStatus.bind(this) } />
    )
  }
}

AddPaymentAction.propTypes = {
  encounterRoutes: React.PropTypes.object.isRequired,
  commentValue: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
};
