class RejectionSelect extends React.Component {
  render() {
    return(
      <select className="input-large">
        {
          this.props.rejectReasons.map( function(rejectReason, iterator) {
            return(
              <option key={ iterator } value={ rejectReason.id }>{ rejectReason.text }</option>
            );
          })
        }
      </select>
    )
  }
}

RejectionSelect.propTypes = {
  rejectReasons: React.PropTypes.array.isRequired,
}
