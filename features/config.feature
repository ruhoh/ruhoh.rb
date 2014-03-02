Feature: Config
  As a content publisher
  I want to configure the way my site works
  so I can publish content in a way that makes me happy.

  Scenario: Setting a production_url
    Given some files with values:
      | file       | body |
      | config.yml | production_url: 'http://hello-world.com' |
      | _root/index.html | <span>{{ urls.production }}</span> |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "span|http://hello-world.com"

  Scenario: Setting a production_url and using legacy urls.production_url
    Given some files with values:
      | file       | body |
      | config.yml | production_url: 'http://hello-world.com' |
      | _root/index.html | <span>{{ urls.production_url }}</span> |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "span|http://hello-world.com"

  Scenario: Compass config.rb files should not be parsed when loading configs
    Given some files with values:
      | file       | body |
      | config.yml | production_url: 'http://hello-world.com' |
      | config.rb  | this is not YML data |
      | _root/index.html | <span>{{ urls.production_url }}</span> |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "span|http://hello-world.com"
