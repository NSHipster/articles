# frozen_string_literal: true
require 'fileutils'

Jekyll::Hooks.register :site, :post_write do |site|
    site.static_files.select do |f|
        next unless f.relative_path.include?(".well-known")
        FileUtils.cp(f.path, site.dest)
    end
end

