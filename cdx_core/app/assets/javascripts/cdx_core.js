Turbolinks.enableProgressBar()

// Configure leaflet
L.Icon.Default.imagePath = '/assets'

L.Map.mergeOptions({
  sleep: true,
  sleepTime: 500,
  wakeTime: 750,
  sleepNote: false,
  hoverToWake: true,
  sleepOpacity:.7
});

function cdx_init_components(dom) {
  ReactRailsUJS.mountComponents(dom);
}

// Don't use $(document).ready so click handlers don't accumulate
// and we end up firing multiple requests on each click.
$(document).on("ready", function(){
  $(document).on('click', '*[data-href]', function(event){
    if (event.metaKey || event.shiftKey) {
      window.open($(this).data('href'), '_blank');
      return;
    }
    Turbolinks.visit($(this).data('href'));
  });
})


$(document).ready(function(){

  $('.datetimepicker').datetimepicker();

  $('.select2').each(function() {
    var $select = $(this);
    $select.select2({
      width : '100%',
      placeholder: {
        id: "-1",
        text: $select.attr('placeholder'),
        selected:'selected'
      }
    })
  });

  function setFilledClass(elem) {
    window.setTimeout(function(){
      if(elem.val().length > 0) {
          elem.addClass('filled');
      } else {
          elem.removeClass('filled');
      }
    }, 0);
  }

  $("input[type='email'], input[type='password']")
    .on('keydown', function() {
      setFilledClass($(this));
    })
    .each(function() {
      setFilledClass($(this));
    });

  $('form[data-auto-submit]').each(function(){
    var form = $(this);
    var payload = form.serialize();

    var debouncedSubmit = _.debounce(function(){
      var url = buildUrl(form);
      Turbolinks.visit(url.toString(), {});
    }, 2000);

    var submitIfChanged = function() {
      if (payload != form.serialize()) {
        payload = form.serialize();
        debouncedSubmit();
      }
    };

    form.on('change', submitIfChanged);
    form.on('keyup', 'input[type=text]', function(){
      // defer the keyup event so the changes due to the pressed key occur.
      window.setTimeout(submitIfChanged, 0);
    });
  });

  window.buildUrl = function(form) {
    var action = form.attr('action') || window.location.href;
    var url = action + (action.indexOf('?') === -1 ? '?' : '&') + form.serialize();
    return url;
  }

  $(document).on('click', '.tabs .tabs-header a:not(".selected")', function(event) {
    var target = $(event.target);
    var tabsHeader = target.closest('ul');
    $('a', tabsHeader).removeClass('selected');
    target.addClass('selected');
    var tabsContents = target.closest('.tabs').children('.tabs-content');
    tabsContents.removeClass('selected');
    var selectedDiv = tabsContents.eq(target.closest('li').index());
    selectedDiv.addClass('selected');
    if(!selectedDiv.hasClass('loaded')) {
      selectedDiv.addClass('loaded');
      $.get(target.attr('href'), function(data) {
        selectedDiv.html(data);
        cdx_init_components(selectedDiv);
      });
    }
  });

  $(document).on('click', '.tabs .tabs-header a', function(event) {
    event.preventDefault();
  });

  $(".tabs .tabs-header li:first-child a").trigger('click');

  /* Initialize sticky outside the event listener as a cached selector.
   * Also, initialize any needed variables outside the listener for
   * performance reasons - no variable instantiation is happening inside the listener.
   */
  var sticky = $('.fix');
  if (sticky.length > 0) {
    var stickyTop = sticky.offset().top - 30,
        scrollTop,
        scrolled = false,
        $window = $(window);

    /* Bind the scroll Event */
    $window.on('scroll', function (e) {
        scrollTop = $window.scrollTop();

        if (scrollTop >= stickyTop) {
            sticky.addClass('fixed');
        } else if (scrollTop < stickyTop) {
            sticky.removeClass('fixed');
        }
    });
  }

  $(".institution-radio label").on('click', function() {
      $(".institution-container").addClass('active');
      position = $(window).scrollTop()
      if (position < 180) {
        $('html,body').animate({
          scrollTop: position + (180 - position)
        });
      } else {
        $('html,body').animate({
          scrollTop: position - (position - 180)
        });
      }
  });

  var advancedTimeout = null;
  $(".btn-toggle").click(function(){

    // We want to set overflow visible after the expand animation has completed
    var advanced = $(".advanced");
    if (advanced.hasClass('show')) {
      if (advancedTimeout) window.clearTimeout(advancedTimeout);
      advanced.css('overflow', 'hidden');
    } else {
      advancedTimeout = window.setTimeout(function() { advanced.css('overflow', 'visible'); }, 500);
    }

    advanced.toggleClass('show');
    $(this).toggleClass('up');
    return false;
  });


  var $flashn = $(".flash.flash_notice, .flash.flash_error");

  if($flashn.length)
    $flashn.delay(3000).fadeOut(300);

  $('body').on('keydown', 'textarea.resizeable', function(e){
    var textarea = $(e.target);
    textarea.css('height', 'auto').css('height', e.target.scrollHeight);
  });


  // Handle the filter hide/show on the test page
  $(".filtershow").click(function(){
    // We want to set overflow visible after the expand animation has completed
    $(".custom_filters").toggle();
  });

  Mousetrap.bind('alt+p', function(e) {
    window.location.pathname = '/patients/new';
    Mousetrap.unbind('alt+p');
  })

  // Notifications#_form
  // Only show frequency_value when frequency == aggregated
  $('#notification_frequency').on('change', function() {
    if($('#notification_frequency').val() == 'aggregate')
      $('.row.frequency-options').removeClass('nodisplay');
    else
      $('.row.frequency-options').addClass('nodisplay');
  })

  // Notifications#_form
  // Show/Hide elements based on boolean with the class in data-show-optional
  $('input[data-show-optional]').on('change', function() {
    var $input = $(this);
    if($input.is(':checked'))
      $('.row.' + $input.data('show-optional')).removeClass('nodisplay');
    else
      $('.row.' + $input.data('show-optional')).addClass('nodisplay');
  });

  $(function() {
    $('.generic-fieldset-fields').fieldsetEvents();

    $('.generic-fieldset-fields__new').on('click', function(e) {
      e.preventDefault(); e.stopPropagation();

      var $fieldset = $(this).parents('.generic-fieldset');

      var notificationIndex = $('.generic-fieldset-fields', $fieldset).length;
      var $fieldsetFields  = $('.generic-fieldset-fields:last', $fieldset).clone();

      $.each($fieldsetFields.find('input'), function() {
        var $field  = $(this);
        var newId   = $field.attr('id').replace(/_\d_/, '_' + notificationIndex + '_');
        var newName = $field.attr('name').replace(/\[\d\]/, '[' + notificationIndex + ']');
        $field.attr('id', newId);
        $field.attr('name', newName);
        $field.val(null);
      });

      $.each($fieldsetFields.find('label'), function() {
        var $field = $(this);
        var newFor = $field.attr('for').replace(/_\d_/, '_' + notificationIndex + '_');
        $field.attr('for', newFor);
      });

      convertFromSelect2($('.generic-fieldset__select--value', $fieldsetFields));

      $.each($fieldsetFields.find('select'), function() {
        var $field  = $(this);
        $field.removeClass('select2-hidden-accessible');
        $field.next('span.select2').remove();

        var newId   = $field.attr('id').replace(/_\d_/, '_' + notificationIndex + '_');
        var newName = $field.attr('name').replace(/\[\d\]/, '[' + notificationIndex + ']');

        $field.attr('id', newId);
        $field.attr('name', newName);
        $field.val(null);

        $field.select2({
          width : '100%',
          placeholder: {
            id: "-1",
            text: $field.attr('placeholder'),
            selected:'selected'
          }
        });
      });

      $('.generic-fieldset-fields:last', $fieldset).after($fieldsetFields);

      $fieldsetFields.fieldsetEvents();
    });
  })

  //Chrome Browser Notification
  if ( (/chrom(e|ium)/.test(navigator.userAgent.toLowerCase())) && !(/edge/.test(navigator.userAgent.toLowerCase())) ){
  } else {
    var x = document.cookie;

    if( x.indexOf("shown=yes") >= 0) {
    } else {
      alert("CDX is currently only optimised for Chrome - Please change your browser.");
    }
    document.cookie = "shown=yes";
  }

});

function convertToSelect2($element, selectValue) {
  var klass = $element.prop('class');
  var name  = $element.prop('name');
  var id    = $element.prop('id');
  var placeholder = $element.prop('placeholder');
  var value = $element.val();

  var $select2 = $('<select></select>');
  $select2.prop('klass', klass);
  $select2.prop('name', name);
  $select2.prop('id', id);
  $select2.prop('placeholder', placeholder);

  var data = conditionStatuses[selectValue];
  data.unshift({ id: '', text: $element.prop('placeholder')});

  $element.after($select2);

  $select2.select2({
    width : '100%',
    data : data,
    placeholder : {
      id : "-1",
      text : $select2.prop('placeholder'),
      selected :'selected'
    }
  });

  $select2
    .removeClass('generic-fieldset__text--value')
    .addClass('generic-fieldset__select--value');

  $select2.val(value).trigger("change");

  $element.remove();
}

function convertFromSelect2($select2) {
  if(!$select2.length) return;

  var klass = $select2.prop('class');
  var name  = $select2.prop('name');
  var id    = $select2.prop('id');
  var placeholder = $select2.prop('placeholder');
  var value = $select2.val();

  $element = $('<input type=\'text\' />');
  $element
    .prop('class', 'generic-fieldset__text--value')
    .prop('name', name)
    .prop('id', id)
    .prop('placeholder', placeholder);

  $select2.before($element);
  $select2.next().remove();
  $select2.remove();
}

$.fn.fieldsetEvents = function() {
  $.each($(this), function() {
    var $fieldsetFields = $(this);

    $('.generic-fieldset-fields__close', $fieldsetFields).on('click', function(e) {
      e.preventDefault(); e.stopPropagation();

      var $destroyInput = $fieldsetFields.prev('input[type=hidden][class="generic-fieldset-fields__input--destroy"]');
      var $idInput = $fieldsetFields.next('input[type=hidden][class!="generic-fieldset-fields__input--destroy"]');

      if ($destroyInput.length) $destroyInput.val(true);

      if ($('.generic-fieldset-fields', $fieldsetFields.parents('.generic-fieldset:first')).length > 1) {
        $fieldsetFields.remove();
      } else {
        $('input[type=text]', $fieldsetFields).val(null);
        $('select', $fieldsetFields).val(null);
        $('select.select2', $fieldsetFields).select2('val', null, true);
      }
    });

    $('.generic-fieldset__select--condition-type', $fieldsetFields).on('change', function() {
      var $select = $(this);
      var data = conditionFields[$select.val()];
      var $select2 = $('.generic-fieldset__select--field', $fieldsetFields);
      $('option[value!=""]', $select2).remove();
      $select2.select2('destroy').select2({
        width : '100%',
        data : data,
        placeholder : {
          id : "-1",
          text : $select2.prop('placeholder'),
          selected :'selected'
        }
      })

      convertFromSelect2($('.generic-fieldset__select--value', $fieldsetFields));
    })

    $('.generic-fieldset__select--field', $fieldsetFields).on('change', function() {
      if ($('.generic-fieldset__select--field', $fieldsetFields).val() == 'status' || $('.generic-fieldset__select--field', $fieldsetFields).val() == 'result_status')
        convertToSelect2($('.generic-fieldset__text--value', $fieldsetFields), $('.generic-fieldset__select--condition-type', $fieldsetFields).val());
      else
        convertFromSelect2($('.generic-fieldset__select--value', $fieldsetFields));
    })

    // Initialise current select2 if #field is a status
    if($('.generic-fieldset__select--field', $fieldsetFields).val() == 'status' || $('.generic-fieldset__select--field', $fieldsetFields).val() == 'result_status')
      convertToSelect2($('.generic-fieldset__text--value', $fieldsetFields), $('.generic-fieldset__select--condition-type', $fieldsetFields).val());
  })

  return this;
}
