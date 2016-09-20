class TestResultActions extends React.Component{
  updateResult(status) {
    let comment = '';
    const that = this;
    $.ajax({
      url: this.props.updateResultUrl,
      method: 'PUT',
      data: { id: this.props.resultId, patient_result: { result_status: status, comment: comment } }
    }).done( function(data) {
      that.props.updateResultStatus(data['result']);
    }).fail( function(data) {
      alert('Can not update status.')
    });
  }

  render() {
    return(
      <div>
        <button onClick={ this.updateResult.bind(this, 'completed') } className="btn-primary save">Completed</button>
        <button onClick={ this.updateResult.bind(this, 'rejected') } className="btn-link">Reject</button>
      </div>

    )
  }
}

TestResultActions.propTypes = {
  updateResultUrl: React.PropTypes.string.isRequired,
  resultId: React.PropTypes.number.isRequired,
  updateResultStatus: React.PropTypes.func.isRequired,
};
