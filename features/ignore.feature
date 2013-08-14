Feature: Ignored resources
  As a content publisher
  I want to ignore certain folders
  so that I can manage non-website related resources freely without screwing up my website.

  Scenario: Defining an ignored resource (directory)
  Given a config file with values:
    | deploy | { "use" : "ignore" } |
    Given some files with values:
      | file |
      | deploy/hello.md |
    When I compile my site
    Then my compiled site should NOT have the file "deploy/hello/index.html"
    Then my compiled site should NOT have the folder "deploy"
