# frozen_string_literal: true

# surajk_plugin/importer.rb — imports a generated OBJ file into the active
# SketchUp model and (optionally) saves the result as a .skp file.

module SurajkPlugin
  module Importer
    # Import *obj_path* into the currently active SketchUp model.
    #
    # Returns the path to the saved .skp file, or raises on failure.
    #
    # @param obj_path [String]  Absolute path to the generated .obj file.
    # @return [String]          Path to the saved .skp file.
    def self.import_and_save(obj_path)
      raise ArgumentError, "OBJ file not found: #{obj_path}" unless File.exist?(obj_path)

      model = Sketchup.active_model
      raise 'No active SketchUp model' if model.nil?

      # -----------------------------------------------------------------------
      # Import the OBJ using SketchUp's built-in importer.
      # In SketchUp Pro 2021 the OBJ importer is always present.
      # -----------------------------------------------------------------------
      result = model.import(obj_path, false)
      unless result
        raise "SketchUp OBJ import returned false for: #{obj_path}"
      end

      # -----------------------------------------------------------------------
      # Save the model as a .skp file next to the OBJ.
      # -----------------------------------------------------------------------
      skp_path = obj_path.sub(/\.obj\z/i, '.skp')
      saved = model.save(skp_path)
      raise "Failed to save .skp to: #{skp_path}" unless saved

      skp_path
    end

    # Parse *obj_path* manually and build SketchUp geometry.
    # This fallback is used when the built-in importer is unavailable or
    # returns an error.
    #
    # Only a subset of the OBJ format is handled: v, f (triangles/quads).
    #
    # @param obj_path [String]  Absolute path to the .obj file.
    # @return [Sketchup::Group] The created group.
    def self.import_obj_manual(obj_path)
      raise ArgumentError, "OBJ file not found: #{obj_path}" unless File.exist?(obj_path)

      model      = Sketchup.active_model
      entities   = model.active_entities
      group      = entities.add_group
      g_entities = group.entities

      vertices = []
      faces    = []

      File.foreach(obj_path) do |line|
        line.strip!
        next if line.empty? || line.start_with?('#')

        parts = line.split
        case parts[0]
        when 'v'
          # Vertex: v x y z
          vertices << Geom::Point3d.new(
            parts[1].to_f.m,
            parts[2].to_f.m,
            parts[3].to_f.m
          )
        when 'f'
          # Face: f v1 v2 v3 [v4 …]  (indices are 1-based; may have v/vt/vn)
          indices = parts[1..].map { |p| p.split('/')[0].to_i - 1 }
          faces << indices
        end
      end

      faces.each do |indices|
        pts = indices.map { |i| vertices[i] }.compact
        next if pts.length < 3

        begin
          g_entities.add_face(pts)
        rescue StandardError
          # Skip degenerate faces silently.
        end
      end

      group
    end
  end
end
