require 'date'
require 'pp'

Jekyll::Hooks.register :posts, :pre_render do |post|
    next unless post.data['revisions']

    last_revised_on = post.data['revisions'].keys.max
    post.data['last_revised_on'] = last_revised_on
    post.data['revision_description'] = post.data['revisions'][last_revised_on]
end
