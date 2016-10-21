class FormCheckBox extends React.Component {
  render(){
    return(
      <input
        type="checkbox"
        onChange={ this.props.onChange }
        checked={ this.props.checked }
        name={ this.props.name }
        id={ this.props.id }
        value={ this.props.value }
        className={ this.props.className }
      />
    );
  }
}

FormCheckBox.propTypes = {
  onChange: React.PropTypes.func.isRequired,
  checked: React.PropTypes.bool.isRequired,
  name: React.PropTypes.string.isRequired,
  id: React.PropTypes.string.isRequired,
  value: React.PropTypes.string.isRequired,
  className: React.PropTypes.string.isRequired,
}
