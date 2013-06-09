Feature: Data
  As a content publisher
  I want to define arbitrary data objects
  so I can quickly display and iterate through this data within my content

  Scenario: Defining a basic data structure in data.yml
    Given the file "data.yml" with body:
      """
      ---
      name: "jade"
      address:
        city: "alhambra"
      fruits:
        - mango
        - kiwi
      """
      And the file "_root/index.html" with body:
        """
        <name>{{ data.name }}</name>
        <city>{{ data.address.city }}</city>
        <ul>
        {{# data.fruits }}
          <li>{{ . }}</li>
        {{/ data.fruits }}
        </ul>
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "name:jade"
      And this file should contain the content node "city:alhambra"
      And this file should contain the content node "li:mango"
      And this file should contain the content node "li:kiwi"
