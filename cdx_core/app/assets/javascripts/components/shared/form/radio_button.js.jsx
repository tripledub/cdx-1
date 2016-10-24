class FormRadioButton extends React.Component {
  render(){
    return(
      <input
        type="radio"
        onChange={ this.props.onChange }
        checked={ this.props.checked }
        name={ this.props.name }
        id={ this.props.id }
        value={ this.props.value }
      />
    );
  }
}

FormRadioButton.propTypes = {
  onChange: React.PropTypes.func.isRequired,
  checked: React.PropTypes.bool.isRequired,
  name: React.PropTypes.string.isRequired,
  id: React.PropTypes.string.isRequired,
  value: React.PropTypes.string.isRequired,
}
