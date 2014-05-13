namespace :publish do
  task :articles, :locale do |task, args|
    locale = args.locale || "en"
    tld = case locale
            when "en" then "com"
            when "zh" then "cn"
            when "ru" then "ru"
            else
              raise "Unknown TLD"
          end

    system %{
      bundle exec jekyll build --config _config.#{locale}.yml
      find _site/ -iname "*.html" -exec tidy -config tidy.conf {} +
      find _site/ -iname '*.html' -exec gzip -n --best {} +
      find _site/ -iname '*.xml' -exec gzip -n --best {} +

      for f in `find _site/ -iname '*.gz'`; do
        mv $f ${f%.gz}
      done

      s3cmd sync --progress -M --acl-public --add-header 'Content-Encoding:gzip' _site/ s3://nshipster.#{tld}/ --exclude '*.*' --include '*.html' --include '*.xml' --verbose
    }
  end

  task :assets, :locale do |task, args|
    locale = args.locale || "en"
    tld = case locale
            when "en" then "com"
            when "zh" then "cn"
            when "ru" then "ru"
            else
              raise "Unknown TLD"
          end

    system %{
      bundle exec compass compile assets --force
      find assets/css -iname '*.css' -exec gzip -n --best {} +
      for f in `find assets/css -iname '*.gz'`; do
        mv $f ${f%.gz}
      done

      s3cmd put --recursive --progress -M --acl-public --add-header 'Content-Encoding:gzip' assets/css s3://nshipster.#{tld}/

      s3cmd put --progress -M --acl-public assets/favicon.ico s3://nshipster.#{tld}/

      s3cmd sync --progress -M --acl-public assets/ s3://nshipster.#{tld}/ --exclude '*.*' --include '*.png' --verbose
    }
  end

  task :default => [:articles, :assets]
end

task :publish, :locale do |task, args|
  Rake::Task["publish:articles"].invoke(args.locale)
  Rake::Task["publish:assets"].invoke(args.locale)
end

task :default => [:publish]
