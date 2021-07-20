$( document ).ready(function() {
    $("#inicio-view").fadeIn( "slow" );
});

$( "#view-select" ).change(function() {
    $(".view-container").hide();
    $("#" + $( this ).val() + "").fadeIn( "slow" );
});