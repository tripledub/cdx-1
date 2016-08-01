var RequestedTests = React.createClass({
  reqtestsChange: function(e) {
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
    this.props.reqtestsChange(requestedTests);
  },

  render: function() {
    return (
      <div className="row">
        <div className="col-6">
          <label>Tests Requested</label>
        </div>
        <div className="col-6 req_tests_checks">
          <ul>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="microscopy" className="test_for_tb" id="requested_microscopy"/>
              <label htmlFor="requested_microscopy">Microscopy</label>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="xpertmtb" className="test_for_tb" id="requested_xpertmtb"/>
              <label htmlFor="requested_xpertmtb">Xpert MTB/RIF</label>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} className="test_for_tb culture" id="requested_culture"/>
              <label htmlFor="requested_culture">Culture</label>
              <ul className="cformatIndented" id="culture_cultformat_section">
                <li>
                  <input data-parent-target='requested_culture' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="culture_cformat_liquid" name="culture_cformat_liquid"/>
                  <label htmlFor="culture_cformat_liquid">Liquid Culture</label>
                </li>
                <li>
                  <input data-parent-target='requested_culture' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="culture_cformat_solid" name="culture_cformat_solid"/>
                  <label htmlFor="culture_cformat_solid">Solid Culture</label>
                </li>
              </ul>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} className="test_for_tb drugsusceptibility1line" id="requested_drugsusceptibility1line"/>
              <label htmlFor="requested_drugsusceptibility1line">Drug Susceptibility First Line</label>
              <ul className="cformatIndented" id="drugsusceptibility1line_cultformat_section">
                <li>
                  <input data-parent-target='requested_drugsusceptibility1line' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="drugsusceptibility1line_cformat_liquid" name="drugsusceptibility1line_cformat_liquid"/>
                  <label htmlFor="drugsusceptibility1line_cformat_liquid">Liquid Culture</label>
                </li>
                <li>
                  <input data-parent-target='requested_drugsusceptibility1line' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="drugsusceptibility1line_cformat_solid" name="drugsusceptibility1line_cformat_solid"/>
                  <label htmlFor="drugsusceptibility1line_cformat_solid">Solid Culture</label>
                </li>
              </ul>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} className="test_for_tb drugsusceptibility2line" id="requested_drugsusceptibility2line"/>
              <label htmlFor="requested_drugsusceptibility2line">Drug Susceptibility Second Line</label>
              <ul className="cformatIndented" id="drugsusceptibility2line_cultformat_section">
                <li>
                  <input data-parent-target='requested_drugsusceptibility2line' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="drugsusceptibility2line_cformat_liquid" name="drugsusceptibility2line_cformat_liquid"/>
                  <label htmlFor="drugsusceptibility2line_cformat_liquid">Liquid Culture</label>
                </li>
                <li>
                  <input data-parent-target='requested_drugsusceptibility2line' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="drugsusceptibility2line_cformat_solid" name="drugsusceptibility2line_cformat_solid"/>
                  <label htmlFor="drugsusceptibility2line_cformat_solid">Solid Culture</label>
                </li>
              </ul>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} className="test_for_tb lineprobe1" id="requested_lineprobe1"/>
              <label htmlFor="requested_lineprobe1">Line probe assay First Line</label>
              <ul className="cformatIndented" id="lineprobe1_cultformat_section">
                <li>
                  <input data-parent-target='requested_lineprobe1' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="lineprobe1_cformat_liquid" name="lineprobe1_cformat_liquid"/>
                  <label htmlFor="lineprobe1_cformat_liquid">Liquid Culture</label>
                </li>
                <li>
                  <input data-parent-target='requested_lineprobe1' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="lineprobe1_cformat_solid" name="lineprobe1_cformat_solid"/>
                  <label htmlFor="lineprobe1_cformat_solid">Solid Culture</label>
                </li>
              </ul>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} className="test_for_tb lineprobe2" id="requested_lineprobe2"/>
              <label htmlFor="requested_lineprobe2">Line probe assay Second Line</label>
              <ul className="cformatIndented" id="lineprobe2_cultformat_section">
                <li>
                  <input data-parent-target='requested_lineprobe2' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="lineprobe2_cformat_liquid" name="lineprobe2_cformat_liquid"/>
                  <label htmlFor="lineprobe2_cformat_liquid">Liquid Culture</label>
                </li>
                <li>
                  <input data-parent-target='requested_lineprobe2' type="checkbox" onChange={this.reqtestsChange} className="cultureformat" id="lineprobe2_cformat_solid" name="lineprobe2_cformat_solid"/>
                  <label htmlFor="lineprobe2_cformat_solid">Solid Culture</label>
                </li>
              </ul>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="cd4" className="test_for_hiv" id="requested_cd4"/>
              <label htmlFor="requested_cd4">CD4 Count</label>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="viral" className="test_for_hiv" id="requested_viral"/>
              <label htmlFor="requested_viral">Viral Load Count</label>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="hiv" className="test_for_hiv" id="requested_hiv"/>
              <label htmlFor="requested_hiv">HIV 1/2 Detect</label>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="rdt" className="test_for_hiv" id="requested_rdt"/>
              <label htmlFor="requested_rdt">RDT</label>
            </li>
            <li>
              <input type="checkbox" onChange={this.reqtestsChange} name="xpertebola" className="test_for_ebola" id="requested_xpertebola"/>
              <label htmlFor="requested_xpertebola">Xpert Ebola</label>
            </li>
          </ul>
        </div>
      </div>
    );
  }
});
