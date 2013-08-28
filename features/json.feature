Feature: Config
  As a content publisher
  I want the option to configure my site in JSON
  because JSON is the preferred data format for modern web-technologies
  and it benefits me to learn and get used to it, not to mention YAML is more
  problematic than it's worth.

  Scenario: Setting configuration in JSON
    Given some files with values:
      | file       | body |
      | config.json | { "production_url" : "http://hello-world.com" } |
      | _root/index.html | <span>{{ urls.production_url }}</span> |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "span|http://hello-world.com"

  Scenario: Setting Top Metadata in JSON
    Given the file "_root/index.html" with body:
      """
      {
        "title" : "Hello World",
        "author" : "Isosceles",
        "tags" : ["apple", "orange"]
      }

      <title>{{ page.title }}</title>

      <author>{{ page.author }}</author>
      """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "title|Hello World"
      And this file should contain the content node "author|Isosceles"
