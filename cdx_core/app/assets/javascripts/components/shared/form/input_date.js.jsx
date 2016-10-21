class FormInputDate extends React.Component {
  render() {
    return (
      <input
        type="date"
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

FormInputDate.propTypes = {
  defaultValue: React.PropTypes.string.isRequired,
  onChange: React.PropTypes.func.isRequired,
  minValue: React.PropTypes.string.isRequired,
  maxValue: React.PropTypes.string,
  id: React.PropTypes.string.isRequired,
  name: React.PropTypes.string.isRequired,
};
