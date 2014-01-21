Feature: ERB Layouts
  As a content publisher
  I want to create layouts using erb
  so I can be happy since I prefer to use erb

  Scenario: Defining more than two layouts.
    Given some files with values:
      | file               | body                                                           | layout  |
      | layouts/outer.erb | <div id="minimal-outer-layout">outer <%= content %> </div>                 |         |
      | layouts/inner.erb   | <div id="minimal-inner-layout">inner <%= content %> </div>           | outer |
      | layouts/essays.erb  | <div id="minimal-layout"> <%= content %></div>             | inner   |
      | essays/hello.erb    | cookie dough                                                   | essays  |
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div#minimal-outer-layout|inner"
      And this file should contain the content node "div#minimal-inner-layout|cookie dough"
      And this file should NOT contain the content node "div#minimal-inner-layout|outer"
      And this file should NOT contain the content node "div#minimal-layout|outer"
      And this file should NOT contain the content node "div#minimal-layout|inner"
