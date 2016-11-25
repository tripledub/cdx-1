class FormLabel extends React.Component {
  render(){
    return(
      <label htmlFor={ this.props.htmlFor }>
        { this.props.title }
      </label>
    );
  }
}

FormLabel.propTypes = {
  htmlFor: React.PropTypes.string,
  title: React.PropTypes.string.isRequired,
};
