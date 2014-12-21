namespace :articles do
  task :build, [:locale] do |task, args|
    system %{
      bundle exec jekyll build --config _config.#{args.locale}.yml
    }
  end

  task :compress do |task|
    system %{
      find _site/ -iname '*.html' -exec gzip -n --best {} +
      find _site/ -iname '*.xml' -exec gzip -n --best {} +

      for f in `find _site/ -iname '*.gz'`; do
        mv $f ${f%.gz}
      done

      mv _site/products.xml _site/products.gz
    }
  end

  task :deploy, [:tld] do |task, args|
    system %{
      s3cmd sync -c ./.s3cfg                                    \
                 -M                                             \
                 --acl-public                                   \
                 --add-header 'Content-Encoding:gzip'           \
                 --exclude '*.*'                                \
                 --include '*.html'                             \
                 --include '*.xml'                              \
                 --include 'products.gz'                        \
                 --progress                                     \
                 --verbose                                      \
                 _site/ s3://nshipster.#{args.tld}/
    }

    system %{
      s3cmd sync -c ./.s3cfg                                    \
                 --acl-public                                   \
                 --exclude '*.*'                                \
                 --include '*.txt'                              \
                 --progress                                     \
                 --verbose                                      \
                 _site/ s3://nshipster.#{args.tld}/
    }
  end
end

namespace :assets do
  # namespace :images do
  # end

  namespace :stylesheets do
    task :build do
      system %{
        bundle exec sass --force -t compressed --update assets/sass:assets/css
      }
    end

    task :compress do
      system %{
        find assets/css -iname '*.css' -exec gzip -n --best {} +
        for f in `find assets/css -iname '*.gz'`; do
          mv $f ${f%.gz}
        done
      }
    end

    task :deploy, [:tld] do
      system %{
        s3cmd put -c ./.s3cfg                                    \
                  -M                                             \
                  --acl-public                                   \
                  --add-header 'Content-Encoding:gzip'           \
                  --recursive                                    \
                  --progress                                     \
                  --verbose                                      \
                  assets/css s3://nshipster.#{args.tld}/
      }
    end
  end

  namespace :javascripts do
    task :deploy, [:tld] do
      system %{
        s3cmd put -c ./.s3cfg                                    \
                  -M                                             \
                  --acl-public                                   \
                  --recursive                                    \
                  --progress                                     \
                  --verbose                                      \
                  assets/js s3://nshipster.#{args.tld}/
      }
    end
  end

  namespace :fonts do
    task :deploy, [:tld] do
      system %{
        s3cmd put -c ./.s3cfg                                    \
                  -M                                             \
                  --acl-public                                   \
                  --recursive                                    \
                  --progress                                     \
                  --verbose                                      \
                  assets/fonts s3://nshipster.#{args.tld}/
      }
    end
  end

  namespace :icons do
    task :deploy, [:tld] do
      system %{
        s3cmd put -c ./.s3cfg                                    \
                  -M                                             \
                  --acl-public                                   \
                  --recursive                                    \
                  --progress                                     \
                  --verbose                                      \
                  assets/favicon.ico s3://nshipster.#{args.tld}/
      }

      system %{
        s3cmd sync -c ./.s3cfg                                   \
                   -M                                            \
                   --acl-public                                  \
                   --exclude '*.*'                               \
                   --include '*.png'                             \
                   --progress                                    \
                   --verbose                                     \
                   assets/ s3://nshipster.#{args.tld}/
      }
    end
  end
end

task :publish, [:locale] do |task, args|
  locale = args.locale || "en"

  Rake::Task["articles:build"].invoke(locale)
  Rake::Task["articles:compress"].invoke
  Rake::Task["articles:deploy"].invoke(tld_for_locale(locale))
end

task :default => [:publish]

private

def tld_for_locale(locale)
  return case locale
            when "en" then "com"
            when "zh" then "cn"
            when "ru" then "ru"
            else
              raise "Invalid Locale"
          end
end
