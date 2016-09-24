class AddPatientResultAction extends React.Component {
  render() {
    return(
      <a className="btn-primary" href={ this.props.editResultUrl }>
        Add result
      </a>
    )
  }
}

AddPatientResultAction.propTypes = {
  editResultUrl: React.PropTypes.string.isRequired,
}
