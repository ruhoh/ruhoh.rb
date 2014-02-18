Feature: Asset Pipeline
  As a content publisher
  I want to use the asset pipeline
  so I can improve my productivity

  Scenario: Stylesheets
    Given some files with values:
      | file       | body |
      | config.json | { "asset_pipeline" : { "enable" : true } } |
      And the file "index.html" with body:
        """
        {{# stylesheets.load }}
          application.css
        {{/ stylesheets.load }}
        """

      And the file "stylesheets/application.css" with body:
        """
        //= require ./test
        """
      And the file "stylesheets/test.css.scss" with body:
        """
        body {
          p {
            &:hover {
              color:red;
            }
            &.active {
              font-weight: bold;
            }
          }
        }
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the fingerprinted stylesheets "application"

  Scenario: Javascripts
    Given some files with values:
      | file       | body |
      | config.json | { "asset_pipeline" : { "enable" : true } } |
      And the file "index.html" with body:
        """
        {{# javascripts.load }}
          application.js
        {{/ javascripts.load }}
        """

      And the file "javascripts/application.js" with body:
        """
        //= require ./test
        """
      And the file "javascripts/test.js" with body:
        """
        var hi = "hi";
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the fingerprinted javascripts "application"



