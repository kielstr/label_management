
(function( $ ){
    $.fn.displayServerError = function() {
        if ( $("#server-error").length > 0) {

            console.log('display_server_errors');

            var msg = '<h1>Some fields are incorrect</h1><ul>';
            $( "#server-error li" ).each( function () {
                msg += '<li>' + $(this).text() + '</li>';
            });
            msg += '</ul>';

            alertify.alert(
                msg,
                function() {},
                "my-breed"
            );

            $( ".required input[type='text']" ).attr( "style", "border-color: red");
            //$( ".required input" ).attr( "placeholder", "Required");
        }

        return 1; 
    },

    $.fn.validateEmail = function () {
        var filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
        if (filter.test(this.val())) {
            return true;
        }
        else {
            return false;
        }
    }; 
})( jQuery );

$(document).ready(function () {
    jQuery().displayServerError();

    $( "#profileMenuIcon" ).click( function() {
        $( "#profileDropDown" ).toggle();
    });

});