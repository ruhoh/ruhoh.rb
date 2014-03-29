Feature: RSS
  As a content publisher
  I want to generate RSS feed for my posts
  so that my blog subscribers can track my writings

  Scenario: Generate RSS feed if enabled
    Given a config file with value:
      """
      {
        "production_url" : "http://www.fakedomain.com",
        "posts" : { "rss" : { "enable" : true } }
      }
      """
    And some files with values:
      | file | body |
      | posts/watermelon.html | I like to eat watermelon =) |
      | posts/orange.html | I do not like to eat orange |
    When I compile my site
    Then my compiled site should have the file "posts/rss.xml"
      And this file should contain the content "http://www.fakedomain.com"
      And this file should contain the content "I like to eat watermelon =)"
      And this file should contain the content "I do not like to eat orange"

  Scenario: Do not generate RSS feed if not enabled
    Given a config file with value:
      """
      {
        "production_url" : "http://www.fakedomain.com",
        "posts" : { "rss" : { "enable" : false } }
      }
      """
    And some files with values:
      | file | body |
      | posts/watermelon.html | I like to eat watermelon =) |
      | posts/orange.html | I do not like to eat orange |
    When I compile my site
    Then my compiled site should NOT have the file "posts/rss.xml"

  Scenario: Generate RSS feed with all relative urls converted to absolute urls to support various feed readers including feedburner and emailed posts
    Given a config file with value:
      """
      {
        "production_url" : "http://www.fakedomain.com",
        "posts" : { "rss" : { "enable" : true } }
      }
      """
    And some files with values:
      | file | body |
      | posts/watermelon.html | I like to eat <a href="articles/fruits/fav.html">watermelon</a> =)|
      | posts/orange.html | I do not like to eat <a href="http://www.othersite.com/fruits/orange.html">orange</a> |
      | posts/apple.html | I like to eat <a href="articles/fruits/fav.html">apple</a> <img src="/images/smiley.html"><span> especially <a href="articles/fruits/red-apples.html">red ones</a></span> |
    When I compile my site
    Then my compiled site should have the file "posts/rss.xml"
      And this file should contain the content "I like to eat <a href="http://www.fakedomain.com/articles/fruits/fav.html">watermelon</a> =)"
      And this file should contain the content "I do not like to eat <a href="http://www.othersite.com/fruits/orange.html">orange</a>"
      And this file should contain the content "I like to eat <a href="http://www.fakedomain.com/articles/fruits/fav.html">apple</a> <img src="http://www.fakedomain.com/images/smiley.html"><span> especially <a href="http://www.fakedomain.com/articles/fruits/red-apples.html">red ones</a></span>"
