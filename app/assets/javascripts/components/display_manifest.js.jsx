var DisplayManifest = React.createClass({
  getInitialState: function() {
    $( "#upload-new-file-id" ).addClass( "hidden" );
    return {
      display_manifest_class: ''
    };
  },
  clickHandler: function() {
    $( "#upload-new-file-id" ).removeClass( "hidden" );
    this.setState( {
    display_manifest_class: 'hidden'
    });
    document.getElementById('deleted_manifest_id').value = this.props.manifest_id.toString();
  },
  render: function() {
    return (
    <div className={this.state.display_manifest_class}>
      <div className="file-upload">
        <label className="input on">
        <a href={this.props.manifest_path}>{this.props.manifest_filename}</a>
        <a className="clear-label" onClick={this.clickHandler}>
          <Img src="/assets/ic-cross.png" />
        </a>
        </label>
      </div>
    </div>
    );
  }
});
