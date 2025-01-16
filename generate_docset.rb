require "logger"

require "active_record"
require "fileutils"

include FileUtils

suffix = ENV["SUFFIX"] || raise("SUFFIX required")
docset_name = "test-#{suffix}"


rm_rf "#{docset_name}.docset"
mkdir_p "#{docset_name}.docset/Contents/Resources/Documents"

File.write(
  "#{docset_name}.docset/Contents/Resources/Documents/index.html",
  <<~HTML,
    <html><body>hello world</body></html>
  HTML
)

File.write(
  "#{docset_name}.docset/Contents/Info.plist",
  <<~XML,
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleIdentifier</key>
      <string>#{docset_name}</string>
      <key>CFBundleName</key>
      <string>#{docset_name}</string>
      <key>DocSetPlatformFamily</key>
      <string>#{docset_name}</string>
      <key>isDashDocset</key>
      <true/>
    </dict>
    </plist>
  XML
)

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "#{docset_name}.docset/Contents/Resources/docSet.dsidx",
)

ActiveRecord::Base.connection.execute(
  <<~SQL,
    CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
  SQL
)

class SearchIndex < ActiveRecord::Base
  self.table_name = "searchIndex"
  self.inheritance_column = "active_record_type"
end

SearchIndex.create(
  name: "hello world",
  type: "Guide",
  path: "index.html",
)
