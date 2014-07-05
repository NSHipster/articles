module Jekyll
  module UniqFilter
    REGEX = /(?:([a-z])([A-Z]+))/

    def uniq(array)
      array.compact.uniq
    end
  end
end

Liquid::Template.register_filter(Jekyll::UniqFilter)
