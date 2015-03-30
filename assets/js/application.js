$(document).ready(function() {
  var group = [];
  $('.highlight').each(function() {
      group.push($(this));

      if(!$(this).next().hasClass('highlight')) {
        var container = $('<div class="highlight-group"></div>');
        container.insertBefore(group[0]);

        for (i in group) {
            group[i].appendTo(container);
        }

        group = [];
      }
  });
  
  var hiddenSingleLanguages = $("meta[property='nshipster:hide-single-lang']").attr('content').split(',');
  
  $('.highlight-group').each(function() {
    var languages = [];
    $(this).find($("code")).each(function() {
      languages.push($(this).data('lang'));
    });

    if ((languages.length == 1) && (hiddenSingleLanguages.indexOf(languages[0].toLowerCase()) != -1)) {
        return;
    }
    
    $(this).children('.highlight:not(:first-child)').hide();

    var span = $('<span class="language-toggle"></span>');
    for (i in languages) {
      var language = languages[i];
      var a = $('<a data-lang="' + language + '">' + language.toProperCase() + '</a>');
      if (i == 0) {
        a.addClass('active');
      }
      span.append(a);
    }

    $(this).prepend(span);
  });


  var showAllWithLanguage = function(lang) {
    $('a[data-lang=' + lang + ']').each( function() {
      $(this).siblings('a').removeClass('active');
      $(this).addClass('active');
      $(this).parent().siblings('.highlight').each(function() {
        if ($(this).find('code').data('lang') === lang) {
          $(this).show();
        } else {
          $(this).hide()
        }
      });
    });
  };

  $('a[data-lang]').on('click', function() {
    var lang = $(this).data('lang');
    if (['swift', 'objective-c'].indexOf(lang) != -1) {
      $.fn.cookie('pref-lang', lang, { expires : 3650, path: '/' });
    }
    showAllWithLanguage(lang);
  });
  
  var preferredLanguage = $.fn.cookie('pref-lang');
  if (preferredLanguage) {
    showAllWithLanguage(preferredLanguage);
  }
});

String.prototype.toProperCase = function() {
  switch (this.toLowerCase()) {
    case 'json': return 'JSON';
    case 'javascript': return 'JavaScript';
    default: return this.replace(/\b\w+/g, function(txt) { return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase(); })
  }
};

// Zepto.cookie plugin
// 
// Copyright (c) 2010, 2012 
// @author Klaus Hartl (stilbuero.de)
// @author Daniel Lacy (daniellacy.com)
// 
// Dual licensed under the MIT and GPL licenses:
// http://www.opensource.org/licenses/mit-license.php
// http://www.gnu.org/licenses/gpl.html
;(function($){
    $.extend($.fn, {
cookie : function (key, value, options) {
var days, time, result, decode
// A key and value were given. Set cookie.
if (arguments.length > 1 && String(value) !== "[object Object]") {
// Enforce object
                options = $.extend({}, options)
if (value === null || value === undefined) options.expires = -1
if (typeof options.expires === 'number') {
                    days = (options.expires * 24 * 60 * 60 * 1000)
                    time = options.expires = new Date()
                    time.setTime(time.getTime() + days)
                }
                value = String(value)
return (document.cookie = [
                    encodeURIComponent(key), '=',
                    options.raw ? value : encodeURIComponent(value),
                    options.expires ? '; expires=' + options.expires.toUTCString() : '',
                    options.path ? '; path=' + options.path : '',
                    options.domain ? '; domain=' + options.domain : '',
                    options.secure ? '; secure' : ''
                ].join(''))
            }
// Key and possibly options given, get cookie
            options = value || {}
            decode = options.raw ? function (s) { return s } : decodeURIComponent
return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null
        }
    })
})(Zepto)