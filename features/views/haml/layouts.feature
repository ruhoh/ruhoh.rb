Feature: Haml layouts
  As a content publisher
  I want to create layouts using haml
  so I can be happy since I prefer to use haml

  Scenario: Defining more than two layouts.
    Given the file "layouts/outer.haml" with body:
      """
      #minimal-outer-layout
        outer
        = content
      """
      And the file "layouts/inner.haml" with body:
        """
        ---
        layout: "outer"
        ---
        #minimal-inner-layout
          inner
          = content
        """
      And the file "layouts/essays.haml" with body:
        """
        ---
        layout: "inner"
        ---
        #minimal-layout
          = content
        """
      And the file "essays/hello.md" with body:
        """
        cookie dough
        """
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div#minimal-outer-layout|inner"
      And this file should contain the content node "div#minimal-inner-layout|cookie dough"
      And this file should NOT contain the content node "div#minimal-inner-layout|outer"
      And this file should NOT contain the content node "div#minimal-layout|outer"
      And this file should NOT contain the content node "div#minimal-layout|inner"
