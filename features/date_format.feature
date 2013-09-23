Feature: Date Formatting
  As a content publisher
  I want my dates to be formated correctly
  so that I can ...

  Scenario Outline: Date with configured date_format and correct dates
    Given a config file with value:
      """
      { "date_format": "<date-format>" }
      """
      And some files with values:
        | file              | date    | body            |
        | _root/index.html  | <date>  | {{ page.date }} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content "<formated-date>"
    Examples:
      | date        | date-format | formated-date     |
      | 2013-12-11  | %Y.%m       | 2013.12           |
      | 2012-01-1   |             |                   |
      | 1991.11.11  | %B %d, %Y   | November 11, 1991 |
      | 0-1-2       | %d/%m/%y    | 02/01/00          |


  Scenario: Date without a configured date_format
    Given some files with values:
        | file              | date    | body            |
        | _root/index.html  | 2013.12.11 | {{ page.date }} |
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content "2013-12-11"

  Scenario: Invalid date
    Given some files with values:
        | file              | date  | body            |
        | _root/index.html  | 0-0   | {{ page.date }} |
    When I try to compile my site
    Then it should fail with:
      """
      ArgumentError: The date '0-0' specified in 'index.html' is unparsable.
      """
