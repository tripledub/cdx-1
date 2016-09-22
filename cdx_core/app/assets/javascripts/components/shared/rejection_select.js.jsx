class RejectionSelect extends React.Component {
  reasonChange(e) {
    e.preventDefault;
    this.props.reasonChange(e.target.value);
  }

  render() {
    return(
      <select onChange={ this.reasonChange.bind(this) } className="input-large">
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
  reasonChange: React.PropTypes.func.isRequired,
}
