# frozen_string_literal: true

# surajk_plugin/dialog.rb — HtmlDialog-based UI for surajk plugin.
#
# Workflow:
#   1. User clicks "Select Image" → Ruby opens a file-picker (UI.openpanel)
#      and sends the chosen path back to the HTML page.
#   2. User clicks "Convert to 3D" → Ruby runs the Python engine, imports
#      the generated OBJ, and saves as .skp, streaming status back to HTML.

require_relative 'config'
require_relative 'importer'

module SurajkPlugin
  module Dialog
    HTML_FILE = File.join(File.dirname(__FILE__), 'html', 'dialog.html')

    # Show (or re-focus) the plugin dialog.
    def self.show
      @dialog ||= build_dialog
      unless @dialog.visible?
        @dialog = build_dialog
      end
      @dialog.show
    end

    # ---------------------------------------------------------------------------
    # Private helpers
    # ---------------------------------------------------------------------------

    def self.build_dialog
      props = {
        dialog_title:    Config::DIALOG_TITLE,
        preferences_key: Config::PLUGIN_ID,
        width:           Config::DIALOG_WIDTH,
        height:          Config::DIALOG_HEIGHT,
        resizable:       false
      }
      dlg = UI::HtmlDialog.new(props)
      dlg.set_file(HTML_FILE)
      register_callbacks(dlg)
      dlg
    end
    private_class_method :build_dialog

    def self.register_callbacks(dlg)
      # -----------------------------------------------------------------------
      # Callback: select_image
      # Opens a native file-picker and sends the path back to JS.
      # -----------------------------------------------------------------------
      dlg.add_action_callback('select_image') do |_action_context|
        path = UI.openpanel('Select furniture image', '', Config::IMAGE_FILTER)
        if path
          safe = path.gsub('\\', '\\\\\\\\').gsub("'", "\\'")
          dlg.execute_script("setImagePath('#{safe}')")
        end
      end

      # -----------------------------------------------------------------------
      # Callback: convert_to_3d
      # Runs the engine then imports the result.
      # -----------------------------------------------------------------------
      dlg.add_action_callback('convert_to_3d') do |_action_context, image_path|
        begin
          run_conversion(dlg, image_path.to_s.strip)
        rescue StandardError => e
          send_status(dlg, :error, "Unexpected error: #{e.message}")
        end
      end
    end
    private_class_method :register_callbacks

    # Run the Python engine for *image_path* and import the result.
    def self.run_conversion(dlg, image_path)
      # --- Validate image path -----------------------------------------------
      if image_path.empty?
        send_status(dlg, :error, 'No image selected. Please choose a JPG or PNG file.')
        return
      end

      unless File.exist?(image_path)
        send_status(dlg, :error, "Image file not found:\n#{image_path}")
        return
      end

      ext = File.extname(image_path).downcase
      unless Config::VALID_IMAGE_EXTS.include?(ext)
        send_status(dlg, :error, "Unsupported image type '#{ext}'. Use JPG or PNG.")
        return
      end

      # --- Validate engine bat -----------------------------------------------
      unless File.exist?(Config::ENGINE_BAT)
        send_status(dlg, :error,
                    "Engine launcher not found:\n#{Config::ENGINE_BAT}\n" \
                    "Please ensure the engine/ folder is intact.")
        return
      end

      # --- Ensure output directory exists ------------------------------------
      FileUtils.mkdir_p(Config::OUTPUT_DIR) unless Dir.exist?(Config::OUTPUT_DIR)

      # --- Build the expected OBJ output path --------------------------------
      base_name = File.basename(image_path, File.extname(image_path))
      obj_path  = File.join(Config::OUTPUT_DIR, "#{base_name}.obj")

      send_status(dlg, :info, 'Running AI engine… this may take a moment.')

      # --- Launch the engine -------------------------------------------------
      # We use a quoted Windows call so spaces in paths are handled.
      cmd = "\"#{Config::ENGINE_BAT}\" \"#{image_path}\" \"#{Config::OUTPUT_DIR}\""
      success = system(cmd)

      unless success && File.exist?(obj_path)
        send_status(dlg, :error,
                    "Engine failed or produced no output.\n" \
                    "Expected OBJ at:\n#{obj_path}\n\n" \
                    "Check engine/run_engine.bat and Python installation.")
        return
      end

      send_status(dlg, :info, 'OBJ generated. Importing into SketchUp…')

      # --- Import OBJ --------------------------------------------------------
      begin
        skp_path = Importer.import_and_save(obj_path)
        send_status(dlg, :success,
                    "Done! Model saved to:\n#{skp_path}")
      rescue StandardError => e
        # Fallback: manual OBJ parser
        send_status(dlg, :info,
                    "Built-in importer failed (#{e.message}). Trying manual import…")
        begin
          Importer.import_obj_manual(obj_path)
          skp_path = obj_path.sub(/\.obj\z/i, '.skp')
          Sketchup.active_model.save(skp_path)
          send_status(dlg, :success,
                      "Done (manual import)! Model saved to:\n#{skp_path}")
        rescue StandardError => e2
          send_status(dlg, :error, "Import failed: #{e2.message}")
        end
      end
    end
    private_class_method :run_conversion

    # Send a status update to the dialog's JS statusUpdate() function.
    # level: :info | :success | :error
    def self.send_status(dlg, level, message)
      safe_msg = message.to_s
                        .gsub('\\', '\\\\\\\\')
                        .gsub("'", "\\'")
                        .gsub("\n", '\\n')
      dlg.execute_script("statusUpdate('#{level}', '#{safe_msg}')")
    end
    private_class_method :send_status
  end
end
