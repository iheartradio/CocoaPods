require 'xcodeproj'

class Xcodeproj::Project::Object::PBXNativeTarget
  def asset_catalogs
    results = []
    build_phases.each do |build_phase|
      next if !build_phase.is_a? Xcodeproj::Project::Object::PBXResourcesBuildPhase
      build_phase.files.objects.each do |file|
        next if !file.display_name.end_with? '.xcassets'
        results.push file
      end
    end
    results
  end
end

module Pod
  class Command
    class Internal < Command
      self.abstract_command = true
      self.summary = 'Utility command used by cocoapod itself'

      class ListAssetCatalog < Internal
        self.summary = 'List asset catalog files associated with specified target'

        self.arguments = [
          CLAide::Argument.new('PROJECT', true),
          CLAide::Argument.new('TARGET', true)
        ]

        def initialize(argv)
          @project = argv.shift_argument
          @target = argv.shift_argument
          super
        end

        def validate!
          super
          unless @project && @target
            help! "Usage: pod internal list-asset-catalog <path_to_project> <target_name>"
          end
        end

        def run
          begin
            project = Xcodeproj::Project.open(@project)
            project.targets.each do |target|
              next if target.name != @target
              puts target.asset_catalogs.map {|file| file.file_ref.real_path}.join ' '
            end
          rescue => error
            puts error
          end
        end
      end
    end
  end
end
