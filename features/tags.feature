Feature: Tags
  As a content publisher
  I want to add tags to pages
  so that I can better organize and provide better access to my content for my readers

  Scenario: Displaying a page's tags
    Given some files with values:
      | file | tags | body |
      | essays/hello.md | apple, banana, pear | {{# page.tags }} <span>{{ name }}</span> {{/ page.tags }} |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "span:apple"
      And this file should contain the content node "span:banana"
      And this file should contain the content node "span:pear"

  Scenario: Displaying a collection's tags with counts
    Given some files with values:
      | file | tags | body |
      | _root/index.md | | {{# essays.tags.all }} <span>{{ name }}-{{ count }}</span> {{/ essays.tags.all }} |
      | essays/hello.md | apple, banana, pear | |
      | essays/goodbye.md | apple, banana, pear, watermelon | |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "span:apple-2"
      And this file should contain the content node "span:banana-2"
      And this file should contain the content node "span:pear-2"
      And this file should contain the content node "span:watermelon-1"

  Scenario: Displaying a specific tag from a collection
    Given some files with values:
      | file | tags | body |
      | _root/index.md | | {{# essays.tags.banana }} <span>{{ name }}-{{ count }}</span> {{/ essays.tags.banana }} |
      | essays/hello.md | apple, banana, pear | |
      | essays/goodbye.md | apple, banana, pear, watermelon | |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should NOT contain the content node "span:apple-2"
      And this file should contain the content node "span:banana-2"
  
