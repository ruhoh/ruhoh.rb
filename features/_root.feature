Feature: _root collection
  As a content publisher
  I want to include pages at my domain's root
  so I can organize my content.

  Scenario: Adding a page to the root folder
  Given some files with values:
    | file        |
    | index.html  |
  When I compile my site
  Then my compiled site should have the file "index.html"
