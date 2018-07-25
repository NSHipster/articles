namespace :assets do
    task optimize: ['assets:optimize:png', 'assets:optimize:jpg', 'assets:optimize:gif']

    namespace :optimize do
        task :gif do
            sh %(find assets -type f -name "*.gif" -exec gifsicle -O3 {} -o {} \\;)
        end

      task :jpg do
        sh %(find assets -type f -name "*.jpg" -exec jpegoptim --strip-all {} \\;)
      end

      task :png do
        sh %(find assets -type f -name "*.png" -exec optipng {} \\;)
      end
    end
  end
