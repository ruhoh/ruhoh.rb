Feature: Syntax widget
  As a content publisher
  I want to provide syntax highlighting
  so users can more easily understand code examples I publish

  Scenario: Using prettify syntax highlighter
    Given a config file with value:
      """
      {
        "production_url" : "http://www.fakedomain.com",
        "widgets" : { "syntax" : { "use" : "prettify" } }
      }
      """
      And some files with values:
        | file                       | body |
        | _root/index.md            | {{{ widgets.syntax }}} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the content node "script[src='/assets/widgets/syntax/javascripts/prettify.js']|"
      And my compiled site should have the file "assets/widgets/syntax/javascripts/prettify.js"

  Scenario: Using prettify syntax highlighter with cdn enabled
    Given a config file with value:
      """
      {
        "production_url" : "http://www.fakedomain.com",
        "widgets" : { "syntax" : { "use" : "prettify", "cdn" : { "enable" : true } } }
      }
      """
      And some files with values:
        | file                       | body |
        | _root/index.md            | {{{ widgets.syntax }}} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the content node "script[src='http://cdnjs.cloudflare.com/ajax/libs/prettify/188.0.0/prettify.js']|"
