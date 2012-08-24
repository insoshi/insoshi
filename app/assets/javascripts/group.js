var OSCURRENCY = {};

// indexOf for IE http://bit.ly/haIWRa
[].indexOf || (Array.prototype.indexOf = function(v,n){
  n = (n==null) ? 0 : n; 
  var m = this.length;
  for(var i = n; i < m; i++)
    if(this[i] == v)
       return i;
  return -1;
});

$(function() {

  OSCURRENCY.group_id = find_group();
  OSCURRENCY.routes = [];
  OSCURRENCY.tab_prefix = '#tab_';
  OSCURRENCY.tab = '';
  OSCURRENCY.post_allowed = true;
  OSCURRENCY.notice_fadeout_time = 8000;
  OSCURRENCY.delete_fadeout_time = 4000;
  OSCURRENCY.offers_mode = ''
  OSCURRENCY.reqs_mode = ''

  $("#tabs").tabs({
    select: function(event, ui) {
      // even if you try calling select, this only gets called if it is not already selected 
      OSCURRENCY.tab = ui.tab.hash;
    },
    fx: {}
    });

  // render jquery tabs - they are created with "display: none" to prevent FOUC
  $('ul.ui-tabs-nav').show();

  route('home',     /^#home$/,                                     '/groups/[:group_id]');
  route('home',     /^#member_preferences\/(\d+)\/edit$/,          '/member_preferences/[:1]/edit');
  route('home',     /^#graphs$/,                                   '/groups/[:group_id]/graphs');

  route('exchanges',/^#exchanges\/page=(\d+)/,                     '/groups/[:group_id]/exchanges?page=[:1]');
  route('requests', /^#reqs\/page=(\d+)/,                          '/groups/[:group_id]/reqs?page=[:1]');
  route('offers',   /^#offers\/page=(\d+)/,                        '/groups/[:group_id]/offers?page=[:1]');
  route('people',   /^#people\/page=(\d+)/,                        '/groups/[:group_id]/memberships?page=[:1]');
  route('forum',    /^#forum\/page=(\d+)/,                         '/groups/[:group_id]/forum?page=[:1]');

  route('requests', /^#reqs\/(\d+)$/,                              '/reqs/[:1]');
  route('requests', /^#reqs\/(\d+)\/edit$/,                        '/reqs/[:1]/edit');
  route('requests', /^#reqs\/new$/,                                '/groups/[:group_id]/reqs/new');
  route('offers',   /^#offers\/(\d+)$/,                            '/offers/[:1]');
  route('offers',   /^#offers\/(\d+)\/edit$/,                      '/offers/[:1]/edit');
  route('offers',   /^#offers\/new$/,                              '/groups/[:group_id]/offers/new');

  route('people',   /^#people\/(.+)\/exchanges\/new$/,             '/people/[:1]/exchanges/new?group='+OSCURRENCY.group_id);
  route('offers',   /^#people\/(.+)\/exchanges\/new\/offer=(\d+)$/,'/people/[:1]/exchanges/new?offer=[:2]');
  route('people',   /^#people\/(.+)\/messages\/new$/,              '/people/[:1]/messages/new');
  route('people',   /^#people\/(.+)\/accounts\/(\d+)/,             '/people/[:1]/accounts/[:2]');

  route('people',   /^#memberships\/(\d+)$/,                       '/memberships/[:1]');
  route('forum',    /^#forums\/(\d+)\/topics\/(\d+)$/,             '/forums/[:1]/topics/[:2]');
  route('forum',    /^#forums\/(\d+)\/topics\/(\d+)\/page=(\d+)$/, '/forums/[:1]/topics/[:2]?page=[:3]');
  route('exchanges',/^#exchanges$/,                                '/groups/[:group_id]/exchanges');
  route('forum',    /^#forum$/,                                    '/groups/[:group_id]/forum');

  // request hashes are inconsistent since controller is reqs
  route('requests', /^#requests$/,                                 '/groups/[:group_id]/reqs');
  route('requests', /^#requests\/category_id=$/,                   '/groups/[:group_id]/reqs');
  route('requests', /^#requests\/category_id=(\d+)$/,              '/groups/[:group_id]/reqs?category_id=[:1]');
  route('requests', /^#reqs\/category_id=(\d+)\/page=(\d+)$/,      '/groups/[:group_id]/reqs?category_id=[:1]&page=[:2]');
  route('requests', /^#requests\/neighborhood_id=$/,              '/groups/[:group_id]/reqs');
  route('requests', /^#requests\/neighborhood_id=(\d+)$/,          '/groups/[:group_id]/reqs?neighborhood_id=[:1]');
  route('requests', /^#reqs\/neighborhood_id=(\d+)\/page=(\d+)$/,  '/groups/[:group_id]/reqs?neighborhood_id=[:1]&page=[:2]');

  route('offers',   /^#offers$/,                                   '/groups/[:group_id]/offers');
  route('offers',   /^#offers\/category_id=$/,                     '/groups/[:group_id]/offers');
  route('offers',   /^#offers\/category_id=(\d+)$/,                '/groups/[:group_id]/offers?category_id=[:1]');
  route('offers',   /^#offers\/category_id=(\d+)\/page=(\d+)$/,    '/groups/[:group_id]/offers?category_id=[:1]&page=[:2]');
  route('offers',   /^#offers\/neighborhood_id=$/,                 '/groups/[:group_id]/offers');
  route('offers',   /^#offers\/neighborhood_id=(\d+)$/,            '/groups/[:group_id]/offers?neighborhood_id=[:1]');
  route('offers',   /^#offers\/neighborhood_id=(\d+)\/page=(\d+)$/,'/groups/[:group_id]/offers?neighborhood_id=[:1]&page=[:2]');

  route('people',   /^#people$/,                                   '/groups/[:group_id]/memberships');
  route('people',   /^#people\/category_id=$/,                     '/groups/[:group_id]/memberships');
  route('people',   /^#people\/category_id=(\d+)$/,                '/groups/[:group_id]/memberships?category_id=[:1]');
  route('people',   /^#people\/category_id=(\d+)\/page=(\d+)$/,    '/groups/[:group_id]/memberships?category_id=[:1]&page=[:2]');
  route('people',   /^#people\/neighborhood_id=$/,                 '/groups/[:group_id]/memberships');
  route('people',   /^#people\/neighborhood_id=(\d+)$/,            '/groups/[:group_id]/memberships?neighborhood_id=[:1]');
  route('people',   /^#people\/neighborhood_id=(\d+)\/page=(\d+)$/,'/groups/[:group_id]/memberships?neighborhood_id=[:1]&page=[:2]');

  function find_group() {
    path = window.location.pathname;
    a = path.split('/');
    return a[2];
  }

  function route(tab,path,url) {
    r = {'tab':OSCURRENCY.tab_prefix+tab,'path':path,'url':url};
    OSCURRENCY.routes.push(r);
  }

  function resolve(path) {
    var a = [];
    var url = '';
    var tab = '';
    for(i=0;i<OSCURRENCY.routes.length;i++) {
      r = OSCURRENCY.routes[i];
      if(a = path.match(r['path'])) {
        tab = r['tab'];
        url = r['url'].replace(/\[:group_id\]/,OSCURRENCY.group_id);
        for(j=1;j<a.length;j++) {
          url = url.replace('[:'+j+']',a[j]);
        }
        return [tab,url];
      }
    }
    return ['',''];
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
      if(i>0 && (hash.length > 1)) {
        hash += '/';
      }
      if(a[i*2] != 'groups') {
        hash += a[i*2] + '/' + a[i*2+1];
      }
    }
    if(parseInt(a.length/2) != a.length/2) {
      if(hash.length > 1) {
        hash += '/';
      }
      hash += a[a.length - 1];
    }
    if(query != undefined) {
      if(query.length > 0) {
        var params = query.split('&');
        for(i=0;i<params.length;i++) {
          if(params[i].split('=')[0] != 'group') {
            hash += '/' + params[i];
          }
        }
      }
    }
    return hash;
  }

  function active_option(mode,url) {
    var response = ""
    if('all' == mode) {
      if((-1==url.indexOf('edit')) && (-1==url.indexOf('new'))) {
        response = (-1==url.indexOf('?')) ? "?scope=all" : "&scope=all";
      }
    }
    return response;
  }

  $(window).hashchange( function() {
      var hash = location.hash;
      var js_url = "";
      var tab = "";
      var a = [];
      if(hash.length != 0) {
        var t = $("#tabs");
        a = resolve(hash);
        tab = a[0];
        js_url = a[1];
        if('#tab_offers' == tab) {
          js_url += active_option(OSCURRENCY.offers_mode,js_url);
        } else if('#tab_requests' == tab) {
          js_url += active_option(OSCURRENCY.reqs_mode,js_url);
        }

        if(tab != OSCURRENCY.tab) {
          // for responding to back/forward buttons
          t.tabs('select',tab);
        }
        if(js_url.length != 0) {
          $.ajaxSetup({cache:true});
          $.getScript(js_url);
          $.ajaxSetup({cache:false});
        }
      }
    });

  $(document).bind('ajaxStart', function() {
      $('span.wait').show();
    });

  $(document).bind('ajaxStop', function() { 
      $('span.wait').hide();
      OSCURRENCY.post_allowed = true;
    });

  $("input#bid_expiration_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true,
      dateFormat: "yy-mm-dd"
      });
    });

  $("input#req_due_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true,
      dateFormat: "yy-mm-dd"
      });
    });

  $("input#offer_expiration_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true,
      dateFormat: "yy-mm-dd"
      });
    });

  $('.edit_member_preference, #new_bid, .edit_bid, #new_req, #edit_req, #new_offer, #edit_offer, #new_topic, #new_post, #new_exchange, #new_wall_post, #tabs #new_message').live('submit',function() {
      if(OSCURRENCY.post_allowed) {
        OSCURRENCY.post_allowed = false;
        $.post($(this).attr('action'),$(this).serialize(),null,'script');
      } else {
        alert('request is being processed...');
      }
      return false;
    });

  $('.search_form').live('submit',function() {
      $.get($(this).attr('action'),$(this).serialize(),null,'script');
      return false;
    });

  $('.add_to_memberships').live('click', function() {
      if(confirm('Are you sure?'))
      {
        id_name = $(this).children('a').attr('id');
        $(this).hide();
        var data = (id_name == 'leave_group') ? {'_method': 'delete'} : {};
        $.post($(this).children('a').attr('href'),data,null,'script');
      }
      return false;
    });

  $('.delete_topic, .delete_post, .delete_req, .delete_offer').live('click', function() {
      if(confirm('Delete?'))
      {
        var data = {'_method': 'delete'}
        $.post($(this).attr('href'),data,null,'script');
      }
      return false;
    });

  $('.deactivate_req').live('click', function() {
    var data = {'_method': 'deactivate'}
    $.post($(this).attr('href'),data,null,'script');
    return false;
  });

  $('a.pay_now').live('click', function() {
    window.location.hash = url2hash(this.href);
    return false;
    });

  $('body.groups .pagination a').live('click',function() {
    str = url2hash(this.href);
    // XXX hack until hash is renamed to match
    str = str.replace(/memberships/,'people');
    window.location.hash = str;
    return false;
    });

  $('a[href=' + OSCURRENCY.tab_prefix + 'home]').bind('click',function () {
      window.location.hash = '#home';
    });

  $('a[href=' + OSCURRENCY.tab_prefix + 'forum]').bind('click',function() {
    $('#forum_form').html('');
    window.location.hash = '#forum';
    });

  $('a[href=' + OSCURRENCY.tab_prefix + 'requests]').bind('click',function() {
      window.location.hash = '#requests';
    });

  $('a[href=' + OSCURRENCY.tab_prefix + 'offers]').bind('click',function() {
      window.location.hash = '#offers';
    });

  $('a[href=' + OSCURRENCY.tab_prefix + 'exchanges]').bind('click',function() {
      window.location.hash = '#exchanges';
    });

  $('a[href=' + OSCURRENCY.tab_prefix + 'people]').bind('click',function() {
      window.location.hash = '#people';
    });

  $('.category_filter #req_category_ids').live('change',function() {
    window.location.hash = '#requests/category_id=' + this.value;
    });

  $('.category_filter #offer_category_ids').live('change',function() {
    window.location.hash = '#offers/category_id=' + this.value;
    });

  $('.category_filter #person_category_ids').live('change',function() {
    window.location.hash = '#people/category_id=' + this.value;
    });


  $('.neighborhood_filter #req_neighborhood_ids').live('change',function() {
    window.location.hash = '#requests/neighborhood_id=' + this.value;
    });

  $('.neighborhood_filter #offer_neighborhood_ids').live('change',function() {
    window.location.hash = '#offers/neighborhood_id=' + this.value;
    });

  $('.neighborhood_filter #person_neighborhood_ids').live('change',function() {
    window.location.hash = '#people/neighborhood_id=' + this.value;
    });

  $('a.show-follow').live('click',function() {
    window.location.hash = url2hash(this.href);
    return false;
    });

  $('a.email-link').live('click',function() {
    window.location.hash = url2hash(this.href);
    return false;
    });

  $.fn.make_filter_visible = function() {
      $(this).parent().children().removeClass('filter_selected');
      $(this).addClass('filter_selected');
  };

  $('.toggle-category').live('click',function() {
      $(this).make_filter_visible();
      $('span.category_filter').show();
      $('span.neighborhood_filter').hide();
      return false;
    });

  $('.toggle-neighborhood').live('click',function() {
      $(this).make_filter_visible();
      $('span.category_filter').hide();
      $('span.neighborhood_filter').show();
      return false;
    });

  function change_offers_mode(mode) {
    if(mode != OSCURRENCY.offers_mode) {
      OSCURRENCY.offers_mode = mode;
      if('#offers' == window.location.hash) {
        // force a hash change
        window.location.hash = '#offers/page=1';
      } else {
        window.location.hash = '#offers';
      }
    }
  }

  $('.toggle-active-offers').live('click',function() {
      $(this).make_filter_visible();
      change_offers_mode('');
      return false;
    });

  $('.toggle-all-offers').live('click',function() {
      $(this).make_filter_visible();
      change_offers_mode('all');
      return false;
    });

  function change_reqs_mode(mode) {
    if(mode != OSCURRENCY.reqs_mode) {
      OSCURRENCY.reqs_mode = mode;
      if('#requests' == window.location.hash) {
        // force a hash change
        window.location.hash = '#reqs/page=1';
      } else {
        window.location.hash = '#requests';
      }
    }
  }

  $('.toggle-active-reqs').live('click',function() {
      $(this).make_filter_visible();
      change_reqs_mode('');
      return false;
    });

  $('.toggle-all-reqs').live('click',function() {
      $(this).make_filter_visible();
      change_reqs_mode('all');
      return false;
    });

  $(window).trigger('hashchange');
});

function update_topic() {
  topic_id = $('#topic').attr('data-id');
  after = $('.forum_post:first-child').attr('data-time');
  $.ajaxSetup({cache:true});
  $.getScript('/posts?topic_id=' + topic_id + '&after=' + after);
  $.ajaxSetup({cache:false});
}

