

# frozen_string_literal: true

namespace :publish do
  task :twitter, [:slug] do |_t, args|
    raise 'Missing arg: slug' unless args[:slug]

    configuration = Jekyll.configuration
    site = Jekyll::Site.new(configuration)
    site.process

    post = site.posts.docs.detect { |p| p.data['slug'] == args[:slug] }
    raise "No post found for #{args[:slug]}" unless post

    p post.data['summary']
  end
end

private

def twitter
  Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
end
