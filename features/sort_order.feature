Feature: Page Sort Order
  As a content publisher
  I want to sort pages by a custom criteria
  so my content makes intuitive sense to my audience.

  Scenario: Default sort order - alpha title ascending
    Given some files with values:
      | file | body |
      | essays/hello.md | |
      | essays/zebra.md | |
      | essays/apple.md | |
      And the file "index.md" with body:
      """
      <essays>
        {{# essays.all }}{{ title }}-{{/ essays.all }}
      </essays> 
      """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "essays|Apple-Hello-Zebra-"

  Scenario: Sort order alpha title descending
    Given a config file with value:
      """
      { "essays" : {"sort" : ["title", "desc"]} }
      """
      And some files with values:
        | file |
        | essays/hello.md |
        | essays/zebra.md |
        | essays/apple.md |
        And the file "index.md" with body:
        """
        <essays>
          {{# essays.all }}{{ title }}-{{/ essays.all }}
        </essays> 
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "essays|Zebra-Hello-Apple-"


  Scenario: Sort order date descending
    Given a config file with value:
      """
      { "essays" : { "sort" : ["date", "desc"] } }
      """
      And some files with values:
        | file            | date        |
        | essays/hello.md | 2013-12-01  |
        | essays/zebra.md | 2013-12-10  |
        | essays/apple.md | 2013-12-25  |
        And the file "index.md" with body:
        """
        <essays>
          {{# essays.all }}{{ title }}-{{/ essays.all }}
        </essays> 
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "essays|Apple-Zebra-Hello-"

  Scenario: Sort order date ascending
    Given a config file with value:
      """
      { "essays" : { "sort" : ["date", "asc"] } }
      """
      And some files with values:
        | file            | date        |
        | essays/hello.md | 2013-12-01  |
        | essays/zebra.md | 2013-12-10  |
        | essays/apple.md | 2013-12-25  |
        And the file "index.md" with body:
        """
        <essays>
          {{# essays.all }}{{ title }}-{{/ essays.all }}
        </essays> 
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "essays|Hello-Zebra-Apple-"

  Scenario: Sort order numerically coerced custom-attribute
    Given a config file with value:
      """
      { "essays" : { "sort" : ["position", "asc"] } }
      """
      And some files with values:
        | file            | position    |
        | essays/hello.md | 2  |
        | essays/zebra.md | 1  |
        | essays/apple.md | 3  |
        And the file "index.md" with body:
        """
        <essays>
          {{# essays.all }}{{ title }}-{{/ essays.all }}
        </essays> 
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "essays|Zebra-Hello-Apple-"

  Scenario: Sort order alpha coerced custom-attribute
    Given a config file with value:
      """
      { "essays" : { "sort" : ["position", "asc"] } }
      """
      And some files with values:
        | file            | position |
        | essays/hello.md | c        |
        | essays/zebra.md | b        |
        | essays/apple.md | a        |
        And the file "index.md" with body:
        """
        <essays>
          {{# essays.all }}{{ title }}-{{/ essays.all }}
        </essays> 
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "essays|Apple-Zebra-Hello-"
