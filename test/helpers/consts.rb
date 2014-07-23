module DelphiTests
    PROJECT_PATH = File.expand_path('../../resources/testproject', __FILE__)
    PROJECT_EXE = PROJECT_PATH + '/../../tmp/win32/bin/%s/testproject.exe'
end

module DelphiAndroidTests
    PROJECT_PATH = File.expand_path('../../resources/testproject-android', __FILE__)
    PROJECT_APK = PROJECT_PATH + '/../../tmp/android/bin/%s/TestProject.apk'
end
