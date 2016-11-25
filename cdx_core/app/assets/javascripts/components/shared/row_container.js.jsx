class RowContainer extends React.Component {

  render(){
    let classNames = 'row ';
    if (this.props.classNames) {
      classNames += this.props.classNames;
    };

    return(
      <div className={ classNames }>
        { this.props.children }
      </div>
    );
  }
}

RowContainer.propTypes = {
  classNames: React.PropTypes.string,
}
