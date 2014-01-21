Feature: Partials
  As a content publisher
  I want to maintain partials
  so that I can reuse content without having to write it over and over

  Scenario: Using a partial
    Given some files with values:
      | file | body |
      | partials/watermelon.html | I like to eat watermelon =) |
      | index.md | {{> watermelon.html }} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content "I like to eat watermelon =)"

  Scenario: Using a markdown partial
    Given some files with values:
      | file | body |
      | partials/watermelon.md | ## I like to eat watermelon =) |
      | index.md | {{> watermelon.md }} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "h2|I like to eat watermelon =)"
