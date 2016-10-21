class FormTextArea extends React.Component {
  render() {
    return (
      <textarea
        type="date"
        onChange={ this.props.onChange }
        rows={ this.props.rows }
        maxLength={ this.props.maxLength }
        cols={ this.props.cols }
        value={ this.props.defaultValue }
        id={ this.props.id }
        name={ this.props.name }>
     </textarea>
    );
  }
};

FormTextArea.propTypes = {
  defaultValue: React.PropTypes.string.isRequired,
  onChange: React.PropTypes.func.isRequired,
  maxLength: React.PropTypes.string.isRequired,
  rows: React.PropTypes.string,
  cols: React.PropTypes.string,
  id: React.PropTypes.string.isRequired,
  name: React.PropTypes.string.isRequired,
};
