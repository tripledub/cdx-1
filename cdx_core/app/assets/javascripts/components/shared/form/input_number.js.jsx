class FormInputNumber extends React.Component {
  render() {
    return (
      <input
        type="number"
        min={ this.props.minValue }
        max={ this.props.maxValue }
        onChange={ this.props.onChange }
        value={ this.props.defaultValue }
        id={ this.props.id }
        name={ this.props.name }
      />
    );
  }
};

FormInputNumber.propTypes = {
  defaultValue: React.PropTypes.number.isRequired,
  onChange: React.PropTypes.func.isRequired,
  minValue: React.PropTypes.string.isRequired,
  maxValue: React.PropTypes.string.isRequired,
  id: React.PropTypes.string.isRequired,
  name: React.PropTypes.string.isRequired,
};
