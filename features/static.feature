Feature: Static resources
  As a content publisher
  I want to include static folders
  so that I can statically transfer files over to my website output.

  Scenario: Defining an ignored resource (directory)
  Given a config file with values:
    | recipes | { "use" : "static" } |
    Given some files with values:
      | file |
      | recipes/hello.md |
      | recipes/hi.txt |
      | recipes/yo.html |
      | recipes/cool/data.json |
    When I compile my site
    Then my compiled site should have the file "recipes/hello.md"
    Then my compiled site should have the file "recipes/hi.txt"
    Then my compiled site should have the file "recipes/yo.html"
    Then my compiled site should have the file "recipes/cool/data.json"
