# My Ruhoh

This fork of the ruhoh blogging engine is for my fiddling with various 
features.  For more info, see:

<http://ruhoh.com>

Here are some of the features I'm working on:

## RSS Limit

A new config option allows you to limit the number of posts included in 
the RSS feed.  Default behavior is to include all posts.

    rss:
      limit: 10

## Widget Enhancements

### Widget Helpers

Widgets can now have Ruby helpers, which should be located in a 'helpers'
folder under the widget and named with the ".rb" extension.

    widgets
       my_widget
           helpers
           javascripts
           layouts

### Widget Context

Widget layouts now have access to the current page context, just like other 
layouts and partials.

Note: As a side effect of this, the special "{{config}}" that widgets
used to have passed directly is now part of the global payload under
"{{widgets.<widgetname>.config}}"
