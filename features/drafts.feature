Feature: Drafts
  As a content publisher
  I want to maintain drafts
  so that I can manage work-in-progress content alongside published content

  Scenario: Defining a draft
    Given some files with values:
      | file |
      | essays/drafts/hello.md |
    When I compile my site
    Then my compiled site should NOT have the file "essays/drafts/hello/index.html"
    Then my compiled site should NOT have the file "essays/hello/index.html"

  Scenario: Defining a nested draft
    Given some files with values:
      | file |
      | essays/one/two/drafts/hello.md |
    When I compile my site
    Then my compiled site should NOT have the file "essays/one/two/drafts/hello/index.html"
    Then my compiled site should NOT have the file "essays/one/two/hello/index.html"
  