var RequestedTests = React.createClass({
  onChange: function(e) {
    var requestedTests = '';

    $('.cformatIndented').hide();
    $('.req_tests_checks input:checked').each(function(dd) {
      if ($(this).attr('name')) {
        var elementName  = $(this).attr('name');
        var elementId    = $(this).attr('id');
        var parentTarget = $('#'+elementId).data('parentTarget');

        if (parentTarget) {
          ($('#'+parentTarget).is(':checked') ) ? requestedTests += elementName + '|' : null;
        } else {
          requestedTests += elementName + '|';
        };
      } else {
        currentTest = $(this).attr('class').split(" ").splice(-1);
        $('#' + currentTest + '_cultformat_section').show();
      }
    });
    this.props.onChange('tests_requested', requestedTests);
  },

  render: function() {
    return (
      <div className="row">
        <div className="col-6 flexStart">
          <label>{I18n.t("components.encounters.lbl_tests_requested")}</label>
        </div>
        <div className="col-6 req_tests_checks">
          <ul>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="microscopy" className="test_for_tb" id="requested_microscopy"/>
              <label htmlFor="requested_microscopy">{I18n.t("components.encounters.lbl_microscopy")}</label>
            </li>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="xpertmtb" className="test_for_tb" id="requested_xpertmtb"/>
              <label htmlFor="requested_xpertmtb">{I18n.t("components.encounters.lbl_xpert_mtb")}</label>
            </li>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="cd4" className="test_for_hiv" id="requested_cd4"/>
              <label htmlFor="requested_cd4">{I18n.t("components.encounters.lbl_cd4_count")}</label>
            </li>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="viral" className="test_for_hiv" id="requested_viral"/>
              <label htmlFor="requested_viral">{I18n.t("components.encounters.lbl_viral_count")}</label>
            </li>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="hiv" className="test_for_hiv" id="requested_hiv"/>
              <label htmlFor="requested_hiv">{I18n.t("components.encounters.lbl_hiv_detect")}</label>
            </li>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="rdt" className="test_for_hiv" id="requested_rdt"/>
              <label htmlFor="requested_rdt">{I18n.t("components.encounters.lbl_rdt")}</label>
            </li>
            <li>
              <input type="checkbox" onChange={ this.onChange } name="xpertebola" className="test_for_ebola" id="requested_xpertebola"/>
              <label htmlFor="requested_xpertebola">{I18n.t("components.encounters.lbl_xpert_ebola")}</label>
            </li>
          </ul>
        </div>
      </div>
    );
  }
});
