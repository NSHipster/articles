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

  $('.highlight-group').each(function() {
    var languages = [];
    $(this).find($("code")).each(function() {
      languages.push($(this).data('lang'));
    });

    $(this).children(".highlight:not(:first-child)").hide();

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

  $('a[data-lang]').on('click', function() {
    var lang = $(this).data('lang');
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
});

String.prototype.toProperCase = function () {
  return this.replace(/\b\w+/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
};
