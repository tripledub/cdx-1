$(function() {
  //Track changes on forms
  var form = $('form.new_device_model, form.edit_device_model');
  form.areYouSure({ silent: true });

  //Request confirmation on publish
  $('#device-model-publish').on('click', function(evt) {
    var msg = evt.target.name == 'publish'
      ? I18n.t('stores.device_model.publishing')
      : I18n.t('stores.device_model.withdrawing');
    msg += I18n.t('stores.device_model.sure');
    if (form.hasClass('dirty')) {
      msg += "\n\n" + I18n.t('stores.device_model.pending_changes');
    }

    if (!window.confirm(msg)) {
      evt.preventDefault();
    }
  });

  // recheck delete checkbox if user cancel the open file dialog
  // and ensure delete checkbox is not checked if a files is selected
  $('#device_model_setup_instructions, #device_model_picture').change(function(){
    var fileInput = $(this);
    var deleteCheckbox = $(fileInput.data('remove-checkbox'));
    var isFileChosen = fileInput.val() != '';
    deleteCheckbox.prop('checked', !isFileChosen);
  });

  // Drag Picture to an input file and preview it
  $('#device_model_picture').on('change', function(e) {
      var reader = new FileReader();
      reader.onload = function (event) {

          $('.upload-new-file img').attr('src',event.target.result).addClass('uploaded');
      }
      reader.readAsDataURL(e.target.files[0]);
  });


  // Change the class on the target zone when dragging a file over it
  $(".clear-label").on('click', function () {
    $(this).closest('.file-uploaded').addClass('remove');
  });

});

document.addEventListener("dragenter", function( event ) {
  if ( event.target.className == "upload-picture" ) {
      $('.choose-picture').addClass('on');
  }

}, false);

document.addEventListener("dragleave", function( event ) {
  if ( event.target.className == "upload-picture" ) {
      $('.choose-picture').removeClass('on');
  }
}, false);
