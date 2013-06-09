Feature: Layouts
  As a content publisher
  I want to use layouts
  so that my site can have a unified look and feel while still being highly maintainable.

  Scenario: Not using a layout
    Given some files with values:
      | file              | body | blah |
      | essays/hello.md   |  cookie dough | tee hee |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content "cookie dough"

  Scenario: Defining a default collection layout.
    Given some files with values:
      | file              | body |
      | layouts/essays.md | <div id="minimal-layout">{{{ content }}}</div> |
      | essays/hello.md   | meepio |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div#minimal-layout:meepio"

  Scenario: Defining a layout in page metadata.
    Given some files with values:
      | file              | body                    | layout  |
      | layouts/custom.md | <div id="minimal-layout">{{{ content }}}</div>  |         |
      | essays/hello.md   | meepio                  | custom  |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div#minimal-layout:meepio"

  Scenario: Defining a layout and sub layout.
    Given some files with values:
      | file               | body                         | layout  |
      | layouts/default.md | <div id="minimal-layout">{{{ content }}}</div>       |         |
      | layouts/essays.md  | <div id="minimal-sub-layout">{{{ content }}}</div>   | default |
      | essays/hello.md    | cookie dough                 | essays  |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div#minimal-layout:cookie dough"
      And this file should contain the content node "div#minimal-sub-layout:cookie dough"
