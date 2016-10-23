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


  var flashn = $(".flash.flash_notice");

  flashn.append( "<a class='close-notification'>x</a>" );

  flashn.delay(3000).fadeOut(300);

  $(".close-notification").click(function(){
    flashn.hide();
  });

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
  });
});
