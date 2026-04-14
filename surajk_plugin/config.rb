# frozen_string_literal: true

# surajk_plugin/config.rb — centralised paths and settings for surajk plugin.

module SurajkPlugin
  module Config
    # Absolute path to the root of this plugin (one level above this file).
    PLUGIN_ROOT = File.expand_path('..', File.dirname(__FILE__))

    # --------------------------------------------------------------------------
    # Engine paths
    # --------------------------------------------------------------------------

    # Directory that contains the Python engine.
    ENGINE_DIR = File.join(PLUGIN_ROOT, 'engine')

    # Windows batch launcher that invokes the Python engine.
    ENGINE_BAT = File.join(ENGINE_DIR, 'run_engine.bat')

    # Python engine entry-point script (used when calling python directly).
    ENGINE_SCRIPT = File.join(ENGINE_DIR, 'engine.py')

    # Directory where model weight files should be placed.
    # See engine/models/README.txt for download instructions.
    MODELS_DIR = File.join(ENGINE_DIR, 'models')

    # --------------------------------------------------------------------------
    # Output paths
    # --------------------------------------------------------------------------

    # Default directory where the engine writes its .obj (and optional .mtl /
    # texture) files.  The plugin reads the generated mesh from here.
    OUTPUT_DIR = File.join(PLUGIN_ROOT, 'output')

    # --------------------------------------------------------------------------
    # Image input settings
    # --------------------------------------------------------------------------

    # File-picker filter string used by UI.openpanel.
    IMAGE_FILTER = 'Image Files|*.jpg;*.jpeg;*.png||'

    # Accepted image extensions (lower-case).
    VALID_IMAGE_EXTS = %w[.jpg .jpeg .png].freeze

    # --------------------------------------------------------------------------
    # UI settings
    # --------------------------------------------------------------------------

    DIALOG_TITLE  = 'surajk plugin — Image → 3D'
    DIALOG_WIDTH  = 480
    DIALOG_HEIGHT = 340
  end
end
