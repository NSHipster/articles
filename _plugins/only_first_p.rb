require 'nokogiri'

module Jekyll
  module AssetFilter    
    @@only_first_p_config = nil
    @@only_first_p_default_config = {
          "show_read_more_link" => true,
          "read_more_link_text" => "Read more"
    }
    
    def only_first_p(post)       
      output = "<p>"
      output << Nokogiri::HTML(post["content"]).at_css("p").inner_html
      output << %{</p>}
      
      if only_first_p_config()['show_read_more_link']
        output << %{<a class="readmore" href="#{post["url"]}">}        
        output << only_first_p_config()['read_more_link_text']        
        output << %{</a>}
      end

      output
    end    
    
    def only_first_p_config
      if @@only_first_p_config == nil
        jekyll_configuration = Jekyll.configuration({})
        
        if jekyll_configuration['only_first_p'] == nil
          @@only_first_p_config = @@only_first_p_default_config
        else
          if jekyll_configuration['only_first_p'].kind_of?(Object)
            @@only_first_p_config = {}
            
            @@only_first_p_default_config.each.each do |key,value|              
              if jekyll_configuration['only_first_p'][key] == nil
                @@only_first_p_config[key] = value
              else
                @@only_first_p_config[key] = jekyll_configuration['only_first_p'][key]
              end             
            end
          else
            @@only_first_p_config = @@only_first_p_default_config
          end          
        end
      end
      
      @@only_first_p_config
    end   

  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)