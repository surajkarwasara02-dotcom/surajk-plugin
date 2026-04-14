# frozen_string_literal: true

# surajk_plugin/main.rb — loaded by the SketchUp extension loader.
#
# Responsibility:
#   • Load all sub-modules.
#   • Add a "Plugins > surajk plugin: Image → 3D" menu item.
#   • Guard against double-loading.

require 'fileutils'

require_relative 'config'
require_relative 'importer'
require_relative 'dialog'

module SurajkPlugin
  unless file_loaded?(__FILE__)
    # Add the menu item under Plugins.
    UI.menu('Plugins').add_item("#{PLUGIN_NAME}: Image \u2192 3D") do
      Dialog.show
    end

    file_loaded(__FILE__)
  end
end
