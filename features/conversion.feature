Feature: Page Conversion
  As a content publisher
  I want my pages to be converted using the appropriate parser
  so that I can have a more powerful publishing environment to write content.

  Scenario: Converting a .txt document
    Given some files with values:
      | file              | body | blah |
      | essays/hello.txt   |  cookie dough | tee hee |
    When I compile my site
    Then my compiled site should have the file "essays/hello.txt"
      And this file should contain the content "cookie dough"

  Scenario: Converting a .json document
    Given some files with values:
      | file              | body |
      | essays/hello.json   |  { "hello" : "world" } |
    When I compile my site
    Then my compiled site should have the file "essays/hello.json"

  Scenario: Converting a .md document
    Given some files with values:
      | file              | body |
      | essays/hello.md   |  #cookie dough |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "h1:cookie dough"

  Scenario: Converting a .markdown document
    Given some files with values:
      | file              | body |
      | essays/hello.markdown |  _cookie dough_ |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "em:cookie dough"
