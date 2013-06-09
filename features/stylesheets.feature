Feature: Stylesheets
  As a content publisher
  I want to load stylesheets
  so I can make my content presentation pleasing to the eye and intuitive for my readers

  Scenario: Defining stylesheets
    Given some files with values:
      | file | body |
      | stylesheets/base.css | body { color: black } |
      | stylesheets/app.css | div { color: black } |
      | stylesheets/custom.css | div { color: black } |
      And the file "_root/index.html" with body:
        """
        {{# stylesheets.load }}
          base.css
          app.css
          custom.css
        {{/ stylesheets.load }}",
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the fingerprinted stylesheets "base, app, custom"

  Scenario: Defining stylesheets in a theme
    Given a config file with values:
      | sample_theme | { "use" : "theme" } |
      And some files with values:
        | file | body |
        | stylesheets/base.css | blah {} |
        | sample_theme/stylesheets/app.css | blah {} |
        | sample_theme/stylesheets/custom.css | blah {} |
      And the file "_root/index.html" with body:
        """
        {{# stylesheets.load }}
          base.css
          app.css
          custom.css
        {{/ stylesheets.load }}",
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the fingerprinted stylesheets "base, app, custom"
