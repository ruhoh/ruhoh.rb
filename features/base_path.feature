Feature: base_path
  As a content publisher
  I want to configure base_path
  so I can publish content relative to arbitrary webhost file structure requirements.

  Scenario: Setting base_path
    Given some files with values:
      | file       | body |
      | config.yml | base_path: '/hello/world' |
      | _root/index.html | |
      | essays/water.md | <span>{{ page.url }}</span> |
    When I compile my site
    Then my compiled site should have the file "hello/world/index.html"
      And my compiled site should have the file "hello/world/essays/water/index.html"
      And this file should contain the content node "span|/hello/world/essays/water"

  Scenario: Setting base_path with compile_as_root
    Given some files with values:
      | file       | body |
      | config.yml | base_path: '/hello/world' \ncompile_as_root: true  |
      | _root/index.html | |
      | essays/water.md | <span>{{ page.url }}</span> |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And my compiled site should have the file "essays/water/index.html"
      And this file should contain the content node "span|/hello/world/essays/water"
