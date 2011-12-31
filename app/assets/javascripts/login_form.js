show_openid = function() {
    $('#openid').show();
    $('#standard').hide();
    $('#openid_link').hide();
    $('#standard_link').show();
    createCookie('use_openid', 1, 30);
    $('#openid_url').value = 'http://';
}
show_standard = function() {
    $('#openid').hide();
    $('#standard').show();
    $('#openid_link').show();
    $('#standard_link').hide();
    eraseCookie('use_openid');
    $('#openid_url').value = '';
}

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,"",-1);
}

$(function() {
  $('#openid').hide();
  $('#standard_link').hide();
  $('#noscript').show();

  if (readCookie('use_openid')){
      show_openid();
  }
});

