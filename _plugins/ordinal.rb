module Jekyll
  module OrdinalFilter
    def ordinalize(date)
      date = datetime(date)
      "#{date.strftime('%B')} #{ordinal(date.strftime('%e').to_i)}, #{date.strftime('%Y')}"
    end

    def ordinal(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}<sup>th</sup>"
      else
        case number.to_i % 10
        when 1
          "#{number}<sup>st</sup>"
        when 2
          "#{number}<sup>nd</sup>"
        when 3
          "#{number}<sup>rd</sup>"
        else
          "#{number}<sup>th</sup>"
        end
      end
    end

    private

    def datetime(date)
      case date
      when String
        Time.parse(date)
      else
        date
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::OrdinalFilter)
