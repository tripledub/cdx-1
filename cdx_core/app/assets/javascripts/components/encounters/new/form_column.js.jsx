class EncounterFormColumn extends React.Component {
  render(){
    let classNames = 'col-6 ';
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

EncounterFormColumn.propTypes = {
  classNames: React.PropTypes.string,
}
