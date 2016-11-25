class FormInputText extends React.Component {
  render() {
    return (
      <input
        type="text"
        onChange={ this.props.onChange }
        value={ this.props.defaultValue }
        id={ this.props.id }
        name={ this.props.name }
      />
    );
  }
};

FormInputText.propTypes = {
  defaultValue: React.PropTypes.number.isRequired,
  onChange: React.PropTypes.func.isRequired,
  id: React.PropTypes.string.isRequired,
  name: React.PropTypes.string.isRequired,
};
