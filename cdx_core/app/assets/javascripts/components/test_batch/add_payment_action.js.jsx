class AddPaymentAction extends React.Component{
  render(){
    return(
      <form className="payment-action col-3" method="post" action={ this.props.submitPaymentUrl }>
        <input type='hidden' name='authenticity_token' value={this.props.authenticityToken} />
        <div className="col">
          <button className="btn-primary save pull-right" type="submit" >Mark test order as paid</button>
        </div>
      </form>
    )
  }
}

AddPaymentAction.propTypes = {
  submitPaymentUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
};
