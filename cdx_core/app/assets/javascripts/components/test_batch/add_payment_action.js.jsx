class AddPaymentAction extends React.Component{
  render(){
    return(
      <form className="payment-action col-6" method="post" action={ this.props.submitPaymentUrl }>
        <input type='hidden' name='authenticity_token' value={this.props.authenticityToken} />
        <div className="col">
          <button className="btn-primary save side-link" type="submit" >{ I18n.t('components.payment_action.mark_as_paid') }</button>
        </div>
      </form>
    )
  }
}

AddPaymentAction.propTypes = {
  submitPaymentUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
};
