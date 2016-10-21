class EncounterHeader extends React.Component {
  render(){
    return(
      <RowContainer classNames="labelHeader">
        <EncounterFormColumn>
          <h3>{ this.props.headerTitle }</h3>
        </EncounterFormColumn>
        <EncounterFormColumn>
        </EncounterFormColumn>
      </RowContainer>
    );
  }
}
