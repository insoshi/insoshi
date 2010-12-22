var OSCURRENCY = {};

$(function() {

  OSCURRENCY.group_id = find_group();
  OSCURRENCY.routes = [];
  OSCURRENCY.tab = '';

  route(/^#e\/page=(\d+)/,                   '/groups/[:group_id]?tab=exchanges&page=[:1]');
  route(/^#r\/page=(\d+)/,                   '/groups/[:group_id]?tab=requests&page=[:1]');
  route(/^#o\/page=(\d+)/,                   '/groups/[:group_id]?tab=offers&page=[:1]');
  route(/^#p\/page=(\d+)/,                   '/groups/[:group_id]?tab=people&page=[:1]');

  route(/^#e\/(\d+)$/,                       '/exchanges/[:1]');
  route(/^#r\/(\d+)$/,                       '/reqs/[:1]');
  route(/^#new_req$/,                        '/groups/[:group_id]/new_req');
  route(/^#o\/(\d+)$/,                       '/offers/[:1]');
  route(/^#new_offer$/,                      '/groups/[:group_id]/new_offer');
  route(/^#p\/(.+)\/e\/new$/,                '/people/[:1]/exchanges/new?group='+OSCURRENCY.group_id);
  route(/^#p\/(.+)\/e\/new\/offer=(\d+)$/,   '/people/[:1]/exchanges/new?offer=[:2]');
  route(/^#p\/(.+)\/m\/new$/,                '/people/[:1]/messages/new');
  route(/^#p\/(.+)\/a\/(\d+)/,               '/people/[:1]/accounts/[:2]');
  route(/^#m\/(\d+)$/,                       '/memberships/[:1]');
  route(/^#f\/(\d+)\/t\/(\d+)$/,             '/forums/[:1]/topics/[:2]');
  route(/^#f\/(\d+)\/t\/(\d+)\/page=(\d+)$/, '/forums/[:1]/topics/[:2]?page=[:3]');
  route(/^#e$/,                              '/groups/[:group_id]?tab=exchanges');
  route(/^#f$/,                              '/groups/[:group_id]?tab=forum');
  route(/^#r$/,                              '/groups/[:group_id]?tab=requests');
  route(/^#r\/category_id=(\d+)$/,           '/groups/[:group_id]?tab=requests&category_id=[:1]');
  route(/^#r\/category_id=(\d+)\/page=(\d+)$/,'/groups/[:group_id]?tab=requests&category_id=[:1]&page=[:2]');
  route(/^#o$/,                              '/groups/[:group_id]?tab=offers');
  route(/^#o\/category_id=(\d+)$/,           '/groups/[:group_id]?tab=offers&category_id=[:1]');
  route(/^#o\/category_id=(\d+)\/page=(\d+)$/,'/groups/[:group_id]?tab=offers&category_id=[:1]&page=[:2]');
  route(/^#p$/,                              '/groups/[:group_id]?tab=people');
  route(/^#p\/category_id=(\d+)$/,           '/groups/[:group_id]?tab=people&category_id=[:1]');
  route(/^#p\/category_id=(\d+)\/page=(\d+)$/,'/groups/[:group_id]?tab=people&category_id=[:1]&page=[:2]');

  function find_group() {
    path = window.location.pathname;
    a = path.split('/');
    return a[2];
  }

  function get_url_params(url) {
    var query_string = url.split('?')[1];
    var params = query_string.split('&');
    var params_obj = {};
    for(i=0;i<params.length;i++) {
      a = params[i].split('=');
      params_obj[a[0]] = a[1];
    }
    return params_obj;
  }

  function route(path,url) {
    r = {'path':path,'url':url};
    OSCURRENCY.routes.push(r);
  }

  function resolve(path) {
    var a = [];
    var url = '';
    for(i=0;i<OSCURRENCY.routes.length;i++) {
      r = OSCURRENCY.routes[i];
      if(a = path.match(r['path'])) {
        url = r['url'].replace(/\[:group_id\]/,OSCURRENCY.group_id);
        for(j=1;j<a.length;j++) {
          url = url.replace('[:'+j+']',a[j]);
        }
        return url;
      }
    }
  }

  function parse_url(url) {
    // regular expression for url parsing from Douglas Crockford
    var parse_url = /^(?:([A-Za-z]+):)?(\/{0,3})([0-9.\-A-Za-z]+)(?::(\d+))?(?:\/([^?#]*))?(?:\?([^#]*))?(?:#(.*))?$/;
    return parse_url.exec(url);
  }

  function url2hash(url) {
    names = ['url', 'scheme', 'slash', 'host', 'port','path', 'query', 'hash'];
    result = parse_url(url);
    path = result[names.indexOf('path')]
    query = result[names.indexOf('query')]

    hash = '#';
    a = path.split('/');
    for(i=0;i<parseInt(a.length/2);i++) {
      if(i>0) {
        hash += '/';
      }
      if(a[i*2] != 'groups') {
        hash += a[i*2].slice(0,1) + '/' + a[i*2+1];
      }
    }
    if(parseInt(a.length/2) != a.length/2) {
      if(hash.length > 1) {
        hash += '/';
      }
      hash += a[a.length - 1];
    }
    if(query != undefined) {
      // XXX assuming there is just one query parameter
      if(query.split('=')[0] != 'group') {
        hash += '/' + query;
      }
    }
    return hash;
  }

  $("#tabs").tabs({
    select: function(event, ui) {
      // even if you try calling select, this only gets called if it is not already selected 
      if(ui.tab.hash.slice(0,2) != window.location.hash.slice(0,2)) { 
        window.location.hash = ui.tab.hash.slice(0,2);
        OSCURRENCY.tab = ui.tab.hash.slice(0,2);
      }
    },
    fx: {}
    });

  $(window).hashchange( function() {
      var hash = location.hash;
      var js_url = "";
      if(hash.length != 0) {
        var t = $("#tabs");
        var tab = hash.split('/')[0];
        if(tab != OSCURRENCY.tab) {
          // for responding to back/forward buttons
          t.tabs('select',tab);
        }
        $('span.wait').show();
        js_url = resolve(hash);
        if(js_url.length != 0) {
          $.getScript(js_url);
        }
      }
    });

  $("input#bid_expiration_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true
      });
    });

  $("input#req_due_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true
      });
    });

  $("input#offer_expiration_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true
      });
    });

  $.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
    });

  $("#new_bid").live('submit',function(){
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
  });

  $(".edit_bid").live('submit',function(){
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
  });

  $('#new_req, #new_offer, #new_topic, #new_post, #new_exchange, #new_wall_post, #new_message').live('submit',function() {
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
    });

  $('.add_to_memberships').live('click', function() {
      id_name = $(this).children('a').attr('id');
      $(this).parent().children('.wait').show();
      $(this).hide();
      var data = (id_name == 'leave_group') ? {'_method': 'delete'} : {};
      $.post($(this).children('a').attr('href'),data,null,'script');
      return false;
    });

  $('a.pay_now').live('click', function() {
    window.location.hash = url2hash(this.href);
    return false;
    });

  $('.pagination a').live('click',function() {
    params = get_url_params(this.href);
    if(params['tab']) {
      str = '#' + params['tab'].slice(0,1)
      if(params['category_id']) {
        str += '/category_id=' + params['category_id'];
      }
      str += '/page=' + params['page'];
    } else {
      str = url2hash(this.href);
    }
    window.location.hash = str;
    return false;
    });

  $('a[href=#forum]').bind('click',function() {
    $('#forum_form').html('');
    if('#f' == OSCURRENCY.tab) {
      window.location.hash = '#f';
    }
    });

  $('a[href=#requests]').bind('click',function() {
      if('#r' == OSCURRENCY.tab) {
        window.location.hash = '#r';
      }
    });

  $('a[href=#offers]').bind('click',function() {
      if('#o' == OSCURRENCY.tab) {
        window.location.hash = '#o';
      }
    });

  $('a[href=#exchanges]').bind('click',function() {
      if('#e' == OSCURRENCY.tab) {
        window.location.hash = '#e';
      }
    });

  $('a[href=#people]').bind('click',function() {
      if('#p' == OSCURRENCY.tab) {
        window.location.hash = '#p';
      }
    });

  $('.category_filter #req_category_ids').live('change',function() {
    window.location.hash = '#r/category_id=' + this.value;
    });

  $('.category_filter #offer_category_ids').live('change',function() {
    window.location.hash = '#o/category_id=' + this.value;
    });

  $('.category_filter #person_category_ids').live('change',function() {
    window.location.hash = '#p/category_id=' + this.value;
    });


  $('a.show-follow').live('click',function() {
    window.location.hash = url2hash(this.href);
    return false;
    });

  $('a.email-link').live('click',function() {
    window.location.hash = url2hash(this.href);
    return false;
    });

  $(window).trigger('hashchange');
});
