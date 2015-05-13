# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'test-delphi-android'

module DelphiAndroidTests

  class TestDelphiAndroidXE7 < TestDelphiAndroid
  protected
    def delphi_version
      return '21'
    end

    def setup_required_files
      super
      @required_files << 'assets/internal/module.ext'
      @required_files << 'assets/internal/predefined.db'
      @required_files << 'lib/mips/libTestProject.so'
    end
  end

end
