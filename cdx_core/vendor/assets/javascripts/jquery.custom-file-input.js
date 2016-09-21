/*
  By Osvaldas Valutis, www.osvaldas.info
  Available for use under the MIT License
*/

'use strict';

function custom_input_file( $, window, document, undefined )
{
  $( '.inputfile' ).each( function()
  {
    var $input   = $( this ),
      $label   = $input.next( 'label' ),
      labelVal = $label.html();

    $input.on( 'change', function( e )
    {
      var fileName = '';

      if( this.files && this.files.length > 1 )
        fileName = ( this.getAttribute( 'data-multiple-caption' ) || '' ).replace( '{count}', this.files.length );
      else if( e.target.value )
        fileName = e.target.value.split( '\\' ).pop();

      if( fileName )
        $label.addClass('on').find( 'span' ).html( fileName );
      else
        $label.removeClass('on').html( labelVal );
    });

    // Firefox bug fix
    $input
    .on( 'focus', function(){ $input.addClass( 'has-focus' ); })
    .on( 'blur', function(){ $input.removeClass( 'has-focus' ); });

    function bindClearInput() {
      $input.parent().find('.clear-input').on('click', function() {
        $input.replaceWith($input = $input.clone(true));
        $label.html(labelVal);
        $label.removeClass('on');
        bindClearInput();
        return false;
      });
    }

    bindClearInput();
  });
}

