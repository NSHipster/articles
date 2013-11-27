jekyll build --config _config.en.yml
find _site/ -iname '*.html' -exec gzip -n --best {} +
find _site/ -iname '*.xml' -exec gzip -n --best {} +

for f in `find _site/ -iname '*.gz'`; do
  mv $f ${f%.gz}
done

s3cmd sync --progress -M --acl-public --add-header 'Content-Encoding:gzip' _site/ s3://nshipster.com/ --exclude '*.*' --include '*.html' --include '*.xml' --verbose
