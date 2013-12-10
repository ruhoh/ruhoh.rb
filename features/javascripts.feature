Feature: Javascripts
  As a content publisher
  I want to load javascripts
  so I can make my content interactive

  Scenario: Defining javascripts
    Given some files with values:
      | file | body |
      | javascripts/base.js | var meep; |
      | javascripts/app.js | console.log('haro world') |
      | javascripts/custom.js | console.log('haro world') |
      And the file "_root/index.html" with body:
        """
        {{# javascripts.load }}
          base.js
          app.js
          custom.js
        {{/ javascripts.load }}",
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the fingerprinted javascripts "base, app, custom"

  Scenario: Defining javascripts in a theme
    Given a config file with values:
      | sample_theme | { "use" : "theme" } |
      And some files with values:
        | file | body |
        | javascripts/base.js | var meep; |
        | sample_theme/javascripts/app.js | console.log('haro world') |
        | sample_theme/javascripts/custom.js | (function() {}) |
      And the file "_root/index.html" with body:
        """
        {{# javascripts.load }}
          base.js
          app.js
          custom.js
        {{/ javascripts.load }}",
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should have the fingerprinted javascripts "base, app, custom"

  Scenario: Using javascript objects to resolve url
    Given some files with values:
      | file | body |
      | javascripts/base.js | var meep; |
      | javascripts/app.js | console.log('haro world') |
      | javascripts/custom.js | console.log('haro world') |
      And the file "_root/index.html" with body:
        """
        ---
        custom: base.js
        ---
        {{# page.custom?to_javascripts }}
          <script type="text/javascript" src="{{url}}"></script>
        {{/ page.custom?to_javascripts }}
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And the file should have the fingerprinted javascript "base"

  Scenario: Using javascript object to resolve url and id
    Given some files with values:
      | file | body |
      | javascripts/base.js | var meep; |
      | javascripts/app.js | console.log('haro world') |
      | javascripts/custom.js | console.log('haro world') |
      And the file "_root/index.html" with body:
        """
        {{# javascripts.all }}
          <script type="text/javascript" id="{{id}}" src="{{url}}"></script>
        {{/ javascripts.all }}
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And the file should have the fingerprinted javascript "app, base, custom"

