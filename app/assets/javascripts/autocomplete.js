$(document).ready(function(){
  $("##{form_tag_id}").bind('railsAutocomplete.select', function(event, data){
    /* Submit the new value to update the DB */


    var url = "/vars/#{variable.id}";

    // To prevent xss attacks, a csrf token must be defined as a meta attribute
    var csrf_token = jQuery('meta[name=csrf-token]').attr('content'),
    csrf_param = jQuery('meta[name=csrf-param]').attr('content');

    var submit_data = "_method=" + 'put';
    submit_data += "&" + 'var' + '[' + 'unit_id' + ']=' + data['item']['id'];

    if (csrf_param !== undefined && csrf_token !== undefined) {
      submit_data += "&" + csrf_param + "=" + encodeURIComponent(csrf_token);
    }

    $.ajax({
      type: "PUT",
      dataType: "script",
      url: url,
      contentType: 'application/json',
      data: JSON.stringify({ var:{unit_id:data['item']['id']}, _method:'put', csrf_param: encodeURIComponent(csrf_token) })
    }).done(function( msg ) {
      alert( "Data Saved: " + msg );
    });
  });
});
