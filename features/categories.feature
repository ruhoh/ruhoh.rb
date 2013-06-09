Feature: Categories
  As a content publisher
  I want to add categories to pages
  so that I can better organize and provide better access to my content for my readers

  Scenario: Displaying a page's categories
    Given some files with values:
      | file | categories | body |
      | essays/hello.md | apple, banana, pear | {{# page.categories }} <span>{{ name }}</span> {{/ page.categories }} |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "span:apple"
      And this file should contain the content node "span:banana"
      And this file should contain the content node "span:pear"

  Scenario: Displaying a collection's categories with counts
    Given some files with values:
      | file | categories | body |
      | _root/index.md | | {{# essays.categories.all }} <span>{{ name }}-{{ count }}</span> {{/ essays.categories.all }} |
      | essays/hello.md | apple, banana, pear | |
      | essays/goodbye.md | apple, banana, pear, watermelon | |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "span:apple-2"
      And this file should contain the content node "span:banana-2"
      And this file should contain the content node "span:pear-2"
      And this file should contain the content node "span:watermelon-1"

  Scenario: Displaying a specific categories from a collection
    Given some files with values:
      | file | categories | body |
      | _root/index.md | | {{# essays.categories.banana }} <span>{{ name }}-{{ count }}</span> {{/ essays.categories.banana }} |
      | essays/hello.md | apple, banana, pear | |
      | essays/goodbye.md | apple, banana, pear, watermelon | |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should NOT contain the content node "span:apple-2"
      And this file should contain the content node "span:banana-2"
