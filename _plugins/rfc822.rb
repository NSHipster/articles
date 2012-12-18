module Jekyll
  module RFC822Filter
    def date_to_rfc822(date)
      date.strftime("%a, %d %b %Y %H:%M:%S %z")
    end
  end
end

Liquid::Template.register_filter(Jekyll::RFC822Filter)
