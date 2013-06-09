# The following text samples are taken from "How the leopard got his spots" by Rudyard Kipling
# which, to my knowledge, is in the public domain. source: http://www.world-english.org/stories.htm
Feature: Summary
  As a content publisher
  I want to provide page summaries
  so I can promote more articles throughout the site using summarized teasers.

  Scenario: Summary with configured summary_lines
    Given a config file with values:
      | essays | { "summary_lines" : 2 } |
      And some files with values:
        | file                | body |
        | layouts/essays.md   | {{{ page.summary }}} |
      And the file "essays/hello.md" with body:
      """
      In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass.

      The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair.

      This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives.

      He would indeed! And, also, there was an Ethiopian with bows and arrows (a 'sclusively greyish-brownish-yellowish man he was then), who lived on the High Veldt with the Leopard: and the two used to hunt together -- the Ethiopian with his bows and arrows, and the Leopard 'sclusively with his teeth and claws -- till the Giraffe and the Eland and the Koodoo and the Quagga and all the rest of them didn't know which way to jump, Best Beloved.
      They didn't indeed!
      """
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div.summary:In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass."
      And this file should contain the content node "div.summary:The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair."
      And this file should NOT contain the content "This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives."

  Scenario: Specifying an explicit summary DOM node
    Given some files with values:
      | file                | body |
      | layouts/essays.md   | {{{ page.summary }}} |
      And the file "essays/hello.md" with body:
      """
      In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. 
      The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. 
      This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives. 
      <div class="summary">
        He would indeed! And, also, there was an Ethiopian with bows and arrows (a 'sclusively greyish-brownish-yellowish man he was then), who lived on the High Veldt with the Leopard: and the two used to hunt together -- the Ethiopian with his bows and arrows, and the Leopard 'sclusively with his teeth and claws -- till the Giraffe and the Eland and the Koodoo and the Quagga and all the rest of them didn't know which way to jump, Best Beloved.
      </div>
      They didn't indeed!
      """
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div.summary:He would indeed! And, also, there was an Ethiopian with bows and arrows (a 'sclusively greyish-brownish-yellowish man he was then), who lived on the High Veldt with the Leopard: and the two used to hunt together -- the Ethiopian with his bows and arrows, and the Leopard 'sclusively with his teeth and claws -- till the Giraffe and the Eland and the Koodoo and the Quagga and all the rest of them didn't know which way to jump, Best Beloved."
      And this file should NOT contain the content "In the days when everybody started fair"

  Scenario: Specifying summary_stop_at_header: true
    Given a config file with values:
      | essays | { "summary_stop_at_header" : true } |
      And some files with values:
        | file                | body |
        | layouts/essays.md   | {{{ page.summary }}} |
      And the file "essays/hello.md" with body:
      """
      In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. 

      # Peach Ice Cream

      The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. 
      This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives. 
      He would indeed! And, also, there was an Ethiopian with bows and arrows (a 'sclusively greyish-brownish-yellowish man he was then), who lived on the High Veldt with the Leopard: and the two used to hunt together -- the Ethiopian with his bows and arrows, and the Leopard 'sclusively with his teeth and claws -- till the Giraffe and the Eland and the Koodoo and the Quagga and all the rest of them didn't know which way to jump, Best Beloved.
      They didn't indeed!
      """
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div.summary:In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. "
      And this file should NOT contain the content "The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. "

  Scenario: Specifying summary_stop_at_header: true with header as starting content
    Given a config file with values:
      | essays | { "summary_stop_at_header" : true } |
      And some files with values:
        | file                | body |
        | layouts/essays.md   | {{{ page.summary }}} |
      And the file "essays/hello.md" with body:
      """
      # Peach Ice Cream
      In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. 

      # Coconut
      The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. 
      This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives. 
      He would indeed! And, also, there was an Ethiopian with bows and arrows (a 'sclusively greyish-brownish-yellowish man he was then), who lived on the High Veldt with the Leopard: and the two used to hunt together -- the Ethiopian with his bows and arrows, and the Leopard 'sclusively with his teeth and claws -- till the Giraffe and the Eland and the Koodoo and the Quagga and all the rest of them didn't know which way to jump, Best Beloved.
      They didn't indeed!
      """
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div.summary:In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. "
      And this file should NOT contain the content "The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. "

  Scenario: Specifying summary_stop_at_header with number
    Given a config file with values:
      | essays | { "summary_stop_at_header" : 3 } |
      And some files with values:
        | file                | body |
        | layouts/essays.md   | {{{ page.summary }}} |
      And the file "essays/hello.md" with body:
      """
      # One
      In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. 

      ## Two
      The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. 

      ### Three
      This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives. 
      He would indeed! And, also, there was an Ethiopian with bows and arrows (a 'sclusively greyish-brownish-yellowish man he was then), who lived on the High Veldt with the Leopard: and the two used to hunt together -- the Ethiopian with his bows and arrows, and the Leopard 'sclusively with his teeth and claws -- till the Giraffe and the Eland and the Koodoo and the Quagga and all the rest of them didn't know which way to jump, Best Beloved.
      They didn't indeed!
      """
    When I compile my site
    Then my compiled site should have the file "essays/hello/index.html"
      And this file should contain the content node "div.summary:In the days when everybody started fair, Best Beloved, the Leopard lived in a place called the High Veldt. 'Member it wasn't the Low Veldt, or the Bush Veldt, or the Sour Veldt, but the 'sclusively bare, hot shiny High Veldt, where there was sand and sandy-coloured rock and 'sclusively tufts of sandy-yellowish grass. "
      And this file should contain the content node "div.summary:The Giraffe and the Zebra and the Eland and the Koodoo and the Hartebeest lived there: and they were 'sclusively sandy-yellow-brownish all over; but the Leopard, he was the 'sclusivest sandiest-yellowest-brownest of them all -- a greyish-yellowish catty-shaped kind of beast, and he matched the 'sclusively yellowish-greyish-brownish colour of the High Veldt to one hair. "
      And this file should contain the content node "h1:One"
      And this file should contain the content node "h2:Two"
      And this file should NOT contain the content "This was very bad for the Giraffe and the Zebra and the rest of them: for he would lie down by a 'sclusively yellowish-greyish-brownish stone or clump of grass, and when the Giraffe or the Zebra or the Eland or the Koodoo or the Bush-Buck or the Bonte-Buck came by he would surprise them out of their jumpsome lives. "
