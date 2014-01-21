Feature: ERB Basics
  As a content publisher
  I want to use erb syntax
  so I can be happy because I like using erb

  Scenario: Basic ERB
  Given some files with values:
    | file              | body |
    | _root/index.erb  | <data><%= 1 + 5 %></data> <title><%= page.title %></title> |
  When I compile my site
  Then my compiled site should have the file "index.html"
  And this file should contain the content node "data|6"
  And this file should contain the content node "title|_root"
