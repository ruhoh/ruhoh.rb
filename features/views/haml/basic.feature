Feature: Haml Basics
  As a content publisher
  I want to use haml syntax
  so I can be happy because I like using haml

  Scenario: Basic HAML
  Given the file "_root/index.haml" with body:
    """
    %h2
      = 1 + 5
    %p
      = page.title
    """
  When I compile my site
  Then my compiled site should have the file "index.html"
  And this file should contain the content node "h2|6"
  And this file should contain the content node "p|_root"
