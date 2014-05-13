module Jekyll
  module Uniq
    REGEX = /(?:([a-z])([A-Z]+))/

    def uniq(array)
      array.compact.uniq
    end
  end
end

Liquid::Template.register_filter(Jekyll::Uniq)
