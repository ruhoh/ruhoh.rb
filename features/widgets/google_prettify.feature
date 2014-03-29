Feature: Google Prettify Widget
  As a content publisher
  I want to include widgets on my site
  so I can easily add customized functionality without polluting my content files

  Scenario: Rendering a custom defined widget
    Given a config file with value:
      """
      {
        "production_url" : "http://www.fakedomain.com"
      }
      """
      And some files with values:
        | file                       | body |
        | _root/index.md            | {{{ widgets.google_prettify }}} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the content node "script[src='http://cdnjs.cloudflare.com/ajax/libs/prettify/188.0.0/prettify.js']|"
