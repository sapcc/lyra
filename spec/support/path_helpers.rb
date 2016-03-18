module Gitmirror
  module RSpec
    module PathHelpers

      def tmp_path
        File.expand_path('../../tmp', __FILE__)
      end

      def clean_tmp_path
        FileUtils.rm_rf(tmp_path)
        FileUtils.mkdir_p(tmp_path)
      end
    end
  end
end
