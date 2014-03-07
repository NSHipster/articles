#! /bin/sh

jekyll build --config _config.en.yml
find _site/ -iname "*.html" -exec tidy -config tidy.conf {} +
find _site/ -iname '*.html' -exec gzip -n --best {} +
find _site/ -iname '*.xml' -exec gzip -n --best {} +

for f in `find _site/ -iname '*.gz'`; do
  mv $f ${f%.gz}
done

s3cmd sync --progress -M --acl-public --add-header 'Content-Encoding:gzip' _site/ s3://nshipster.com/ --exclude '*.*' --include '*.html' --include '*.xml' --verbose

compass compile assets --force
find assets/css -iname '*.css' -exec gzip -n --best {} +
for f in `find assets/css -iname '*.gz'`; do
  mv $f ${f%.gz}
done

s3cmd put --recursive --progress -M --acl-public --add-header 'Content-Encoding:gzip' assets/css s3://nshipster.com/
