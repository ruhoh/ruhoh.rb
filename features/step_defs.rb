Transform(/^(should|should NOT)$/) do |matcher|
  matcher.downcase.gsub(' ', '_')
end

Given(/^a config file with value:$/) do |string|
  make_config(JSON.parse(string))
end

Given(/^a config file with values:$/) do |table|
  data = table.rows_hash
  data.each{ |key, value| data[key] = JSON.parse(value) }
  make_config(data)
end

Given(/^the file "(.*)" with body:$/) do |file, body|
  make_file(path: file, body: body)
end

Given(/^some files with values:$/) do |table|
  table.hashes.each do |row|
    file = row['file'] ; row.delete('file')
    body = row['body'] ; row.delete('body')

    make_file(path: file, data: row, body: body)
  end
end

When(/^I try to compile my site$/) do
  begin
    compile
  rescue Exception => e
    @exception = e
  end
end

Then(/^it should fail$/) do
  @exception.should_not be_nil
end

Then(/^it (should|should NOT) fail with:$/) do |matcher, content|
  @exception.should_not be_nil
  Ruhoh.log.buffer.last.__send__(matcher, have_content(content))
end

Then(/^the log (should|should NOT) include:$/) do |matcher, content|
  Ruhoh.log.buffer.__send__(matcher, include(content))
end

When(/^I compile my site$/) do
  compile
end

Then(/^my compiled site (should|should NOT) have the file "(.*?)"$/) do |matcher, path|
  @filepath = path
  FileUtils.cd(@ruhoh.config['compiled']) {
    # Done this way so the error output is more informative.
    files = Dir.glob("**/*").delete_if{ |a| File.directory?(a) }
    files.__send__(matcher, include(path)) 
  }
end

Then(/^my compiled site (should|should NOT) have the (?:directory|folder) "(.*?)"$/) do |matcher, path|
  @filepath = path
  FileUtils.cd(@ruhoh.config['compiled']) {
    # Done this way so the error output is more informative.
    files = Dir.glob("**/*").delete_if{ |a| File.file?(a) }
    files.__send__(matcher, include(path)) 
  }
end

Then(/^this file (should|should NOT) (?:have|contain) the content "(.*?)"$/) do |matcher, content|
  this_compiled_file.__send__(matcher, have_content(content))
end

Then(/^this file (should|should NOT) (?:have|contain) the content node "(.*?)\|(.*?)"$/) do |matcher, node, content|
  if matcher == "should"
    this_compiled_file.__send__(matcher, have_selector(node, visible: false))
  end
  Nokogiri::HTML(this_compiled_file).css(node).text.__send__(matcher, have_content(content))
end

Then(/^this file (should|should NOT) have the links "(.*)"$/) do |matcher, links|
  links = links.split(/[\s,]+/).map(&:strip)
  links.each do |link|
    this_compiled_file.__send__(matcher, have_css("a[href='#{ link }']"))
  end
end

# This is a bit hacky and doesn't verify the fingerprint is valid/accurate.
Then(/^this file (should|should NOT) have the fingerprinted (stylesheets|javascripts) "(.*)"$/) do |matcher, filetype, names|
  names = names.split(/[\s,]+/).map(&:strip)
  files = nil
  FileUtils.cd(File.join(@ruhoh.config['compiled'], 'assets', filetype)){
    files = Dir['*']
  }

  names.each do |name|
    file = files.find{ |a| a.start_with?(name) }
    file.should_not be_nil
    link = "/assets/#{ filetype }/#{ file }"
    selector = (filetype == "stylesheets") ? "link[href='#{ link }']" : "script[src='#{ link }']"
    this_compiled_file.__send__(matcher, have_css(selector, visible: false))
  end
end
