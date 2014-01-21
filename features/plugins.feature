Feature: Plugins
  As a content publisher
  I want to include custom plugins
  so I have the freedom and power to customize my website and workflow.

  Scenario: Loading a pages collection plugin from the plugins folder.
    Given the file "plugins/pages_test.rb" with body:
      """
      module PagesTest
        def test_plugin_method
          "Hi this is output from the test plugin"
        end
      end
      Ruhoh::Collections::Pages::CollectionView.send(:include, PagesTest)
      """
      And the file "index.html" with body:
        """
        <output>{{ _root.test_plugin_method }}</output>
        """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "output|Hi this is output from the test plugin"

  Scenario: Loading a pages model plugin from the plugins folder.
    Given some files with values:
      | file | date | body |
      | index.html | 2013-12-01 | <date>{{ page.friendly_date }}</date> |
    Given the file "plugins/paged_model_view_addons.rb" with body:
      """
      module PagesModelViewAddons
        def friendly_date
          date.strftime("%B %d, %Y")
        end
      end
      Ruhoh::Collections::Pages::ModelView.send(:include, PagesModelViewAddons)
      """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "date|December 01, 2013"

  Scenario: Loading a custom converter from the plugins folder.
    Given some files with values:
      | file | body |
      | index.strip | <output>the quick brown fox jumps over the lazy dog</output> |
    Given the file "plugins/strip_converter.rb" with body:
      """
      class Ruhoh
        module Converter
          module Strip
            def self.extensions
              ['.strip']
            end
            def self.convert(content)
              content.gsub(/\s/, '')
            end
          end
        end
      end
      """
    When I compile my site
    Then my compiled site should have the file "index.html"
      And this file should contain the content node "output|thequickbrownfoxjumpsoverthelazydog"

  Scenario: Loading a custom compiler from the plugins folder.
    Given the file "plugins/test_compiler.rb" with body:
      """
      class Ruhoh
        module Compiler
          class Test
            def initialize(ruhoh)
              @ruhoh = ruhoh
            end
            def run
              File.open(@ruhoh.compiled_path("test-file.txt"), 'w:UTF-8') do |p|
                p.puts "Domo's World ^_^"
              end
            end
          end
        end
      end
      """
    When I compile my site
    Then my compiled site should have the file "test-file.txt"
      And this file should contain the content "Domo's World ^_^"
