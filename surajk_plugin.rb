# frozen_string_literal: true

# surajk_plugin.rb — SketchUp extension loader
# Registers "surajk plugin" with SketchUp Pro 2021 and loads the extension
# only once per session.

require 'sketchup.rb'
require 'extensions.rb'

module SurajkPlugin
  PLUGIN_NAME    = 'surajk plugin'
  PLUGIN_VERSION = '1.0.0'
  PLUGIN_ID      = 'surajk_plugin'

  unless file_loaded?(__FILE__)
    ex = SketchupExtension.new(PLUGIN_NAME, 'surajk_plugin/main')
    ex.description = 'Converts a single furniture photo into an approximate ' \
                     '3D SketchUp model, fully offline on Windows.'
    ex.version     = PLUGIN_VERSION
    ex.copyright   = '2024 Suraj Karwasara'
    ex.creator     = 'Suraj Karwasara'
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end
end
