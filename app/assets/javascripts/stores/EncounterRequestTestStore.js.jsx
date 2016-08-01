var EncounterRequestTestStore = Reflux.createStore({
  init: function() {
    this.listenTo(EncounterRequestTestActions.update, this.onUpdate);
  },

  onUpdate: function(url, requested_tests, successUrl, errorCallback) {
    $.ajax({
      url: url,
      dataType: 'json',
      type: 'PUT',
      data: { 'requested_tests': requested_tests },

      success: function(data) {
        window.location.href = successUrl;
      },

      error: function(xhr, status, err) {
        _message_array = extractResponseErrors(xhr.responseText);
        errorCallback(_message_array);
      }
    });
  }
});
