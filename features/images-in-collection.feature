Feature: Images placed inside pages collections
  As a content publisher
  I want to include images and other binary files alongside pages
  so I can organize my content.

  Scenario: Placing an image inside a pages collection.
    Given some files with values:
      | file        | title    | body                            |
      | index.html  | Good Day | <title>{{ page.title }}</title> |
      And an image at the path "avatar.jpg"
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "title|Good Day"
      And my compiled site should have the file "avatar.jpg"

  Scenario: Image inside a pages collection with custom permalink path.
    Given a config file with values:
      | essays | { "permalink" : ":path/:meta/:filename" } |
    And some files with values:
      | file               | meta |
      | essays/index.html  | one  |
      And an image at the path "essays/avatar.jpg"
    When I compile my site
    Then my compiled site should have the file "essays/one/index.html"
      And my compiled site should have the file "essays/avatar.jpg"

  Scenario: Iterating over pages collection with included image
    Given the file "essays/index.html" with body:
      """
      ---
      title: "Hello"
      ---
      <ul>
      {{# essays.all }}
        <li>{{ title }}</li>
      {{/ essays.all }}"
      </ul>
      """
    And an image at the path "essays/avatar.jpg"
  When I compile my site
  Then my compiled site should have the file "essays/index.html"
    And this file should contain the content node "li|Hello"
    And this file should contain the content node "li|Avatar"
