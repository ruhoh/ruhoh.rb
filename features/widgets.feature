Feature: Widgets
  As a content publisher
  I want to include widgets on my site
  so I can easily add customized functionality without polluting my content files

  Scenario: Rendering a custom defined widget
    Given some files with values:
      | file                       | body |
      | widgets/foo/default.html   | I am a custom widget |
      | essays/hello.md            | {{{ widgets.foo }}} |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should have the content "I am a custom widget"

  Scenario: Rendering a custom defined widget with configuration
    Given the file "widgets/foo/default.html" with body:
      """
      ---
      tracking_id: 123
      address:
        city: seattle
      ---
      <tracking>{{ this_config.tracking_id }}</tracking>
      <address>{{ this_config.address.city }}</address>

      Cool lesson
      """
      And some files with values:
        | file                       | body |
        | essays/hello.md            | {{{ widgets.foo }}} |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should have the content "Cool lesson"
      And this file should have the content node "tracking:123"
      And this file should have the content node "address:seattle"

  Scenario: Rendering a custom defined widget with configuration overrides
    Given the file "config.yml" with body:
      """
      widgets:
        foo:
          tracking_id: 987
          address:
            city: Berkeley
      """
      And the file "widgets/foo/default.html" with body:
        """
        ---
        tracking_id: 123
        address:
          city: seattle
        ---
        <tracking>{{ this_config.tracking_id }}</tracking>
        <address>{{ this_config.address.city }}</address>

        Cool lesson
        """
      And some files with values:
        | file                       | body |
        | essays/hello.md            | {{{ widgets.foo }}} |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should have the content "Cool lesson"
      And this file should have the content node "tracking:987"
      And this file should have the content node "address:Berkeley"
      And this file should NOT have the content node "tracking:123"
      And this file should NOT have the content node "address:seattle"

  Scenario: Rendering a custom defined widget with assets
    Given the file "widgets/foo/default.html" with body:
      """
      <path>{{ this_path }}/style.css</path>
      Cool lesson
      """
      And some files with values:
        | file                       | body |
        | widgets/foo/style.css     | div {} |
        | essays/hello.md            | {{{ widgets.foo }}} |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should have the content "Cool lesson"
      And this file should have the content node "path:/assets/widgets/foo/style.css"
      And my compiled site should have the file "assets/widgets/foo/style.css"
