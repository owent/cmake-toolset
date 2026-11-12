$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'

$OutputEncoding = [System.Text.UTF8Encoding]::new()

$ENV:LC_ALL = "en_US.UTF-8"
$ENV:LANG = "en_US.UTF-8"
$ENV:LANGUAGE = "en_US.UTF-8"

if ( (Test-Path ENV:CI) -or (Test-Path ENV:CI_NAME) ) {
  $ENV:ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE = "true"
  $ENV:ATFRAMEWORK_CMAKE_TOOLSET_VERBOSE = "true"
}

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$WORK_DIR = Get-Location

if ($IsWindows) {
  # See https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=cmd
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
}

Set-Location "$SCRIPT_DIR/.."
$RUN_MODE = $args[0]

$ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS=@("-DATFRAMEWORK_CMAKE_TOOLSET_VERBOSE=TRUE")

if(Test-Path Env:CMAKE_FIND_ROOT_PATH_MODE_PROGRAM) {
  $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS += "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=$Env:CMAKE_FIND_ROOT_PATH_MODE_PROGRAM"
}
if(Test-Path Env:CMAKE_FIND_ROOT_PATH_MODE_LIBRARY) {
  $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS += "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=$Env:CMAKE_FIND_ROOT_PATH_MODE_LIBRARY"
}
if(Test-Path Env:CMAKE_FIND_ROOT_PATH_MODE_INCLUDE) {
  $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS += "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=$Env:CMAKE_FIND_ROOT_PATH_MODE_INCLUDE"
}
if(Test-Path Env:CMAKE_FIND_ROOT_PATH_MODE_PACKAGE) {
  $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS += "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=$Env:CMAKE_FIND_ROOT_PATH_MODE_PACKAGE"
}
if(Test-Path Env:ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM) {
  $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS += "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM=$Env:ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM"
}

if ($IsWindows) {
  if (Test-Path "${Env:USERPROFILE}/scoop/apps/perl/current/perl/bin") {
    $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "${Env:USERPROFILE}/scoop/apps/perl/current/perl/bin"
  }
  
  function Invoke-Environment {
    param
    (
      [Parameter(Mandatory = $true)]
      [string] $Command
    )
    cmd /c "$Command > nul 2>&1 && set" | . { process {
        if ($_ -match '^([^=]+)=(.*)') {
          [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
      } }
  }
  $vswhere = "${ENV:ProgramFiles(x86)}/Microsoft Visual Studio/Installer/vswhere.exe"
  $vsInstallationPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
  $winSDKDir = $(Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SDKs\Windows\v10.0" -Name "InstallationFolder")
  if ([string]::IsNullOrEmpty($winSDKDir)) {
    $winSDKDir = "${ENV:ProgramFiles(x86)}/Windows Kits/10/Include/"
  }
  else {
    $winSDKDir = "$winSDKDir/Include/"
  }
  foreach ($sdk in $(Get-ChildItem $winSDKDir | Sort-Object -Property Name)) {
    if ($sdk.Name -match "[0-9]+\.[0-9]+\.[0-9\.]+") {
      $selectWinSDKVersion = $sdk.Name
    }
  }
  if (!(Test-Path Env:WindowsSDKVersion)) {
    $Env:WindowsSDKVersion = $selectWinSDKVersion
  }
  # Maybe using $selectWinSDKVersion = "10.0.18362.0" for better compatible
  Write-Output "Window SDKs:(Latest: $selectWinSDKVersion)"
  foreach ($sdk in $(Get-ChildItem $winSDKDir | Sort-Object -Property Name)) {
    Write-Output "  - $sdk"
  }

  if (!(Test-Path Env:CMAKE_GENERATOR)) {
    $Env:CMAKE_GENERATOR = "Visual Studio 18 2026"
  }
}

if (!(Test-Path Env:CI_BUILD_CONFIGURE_TYPE)) {
  $Env:CI_BUILD_CONFIGURE_TYPE = "Release"
}

if ( $RUN_MODE -eq "msvc.static.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  Write-Output "<Project>
  <PropertyGroup>
     <UseStructuredOutput>false</UseStructuredOutput>
  </PropertyGroup>
</Project>" > Directory.Build.props
  & cmake .. -G "$Env:CMAKE_GENERATOR" -A x64 -DBUILD_SHARED_LIBS=OFF "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE" `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DVS_GLOBAL_VcpkgEnabled=OFF" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin"
  $TEST_BIN_PATH = Get-ChildItem -Recurse -Path bin -File "*.exe" | Foreach-object {echo $_.Directory.FullName} | Select-Object -First 1
  Get-ChildItem -Recurse -Path ../third_party/install/ -File "*.dll" | Foreach-object { Copy-Item -Force $_ -Destination $TEST_BIN_PATH }
  & ctest . -V -C "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.shared.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  Write-Output "<Project>
  <PropertyGroup>
     <UseStructuredOutput>false</UseStructuredOutput>
  </PropertyGroup>
</Project>" > Directory.Build.props
  & cmake .. -G "$Env:CMAKE_GENERATOR" -A x64 "-DBUILD_SHARED_LIBS=ON" "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE"  `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DVS_GLOBAL_VcpkgEnabled=OFF" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin"
  $TEST_BIN_PATH = Get-ChildItem -Recurse -Path bin -File "*.exe" | Foreach-object {echo $_.Directory.FullName} | Select-Object -First 1
  Get-ChildItem -Recurse -Path ../third_party/install/ -File "*.dll" | Foreach-object { Copy-Item -Force $_ -Destination $TEST_BIN_PATH }
  Write-Output "PATH=$Env:PATH"
  & ctest . -V -C "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.no-rtti.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  Write-Output "<Project>
  <PropertyGroup>
     <UseStructuredOutput>false</UseStructuredOutput>
  </PropertyGroup>
</Project>" > Directory.Build.props
  & cmake .. -G "$Env:CMAKE_GENERATOR" -A x64 "-DBUILD_SHARED_LIBS=ON" "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE"  `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DCOMPILER_OPTION_DEFAULT_ENABLE_RTTI=OFF" "-DVS_GLOBAL_VcpkgEnabled=OFF" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin"
  $TEST_BIN_PATH = Get-ChildItem -Recurse -Path bin -File "*.exe" | Foreach-object {echo $_.Directory.FullName} | Select-Object -First 1
  Get-ChildItem -Recurse -Path ../third_party/install/ -File "*.dll" | Foreach-object { Copy-Item -Force $_ -Destination $TEST_BIN_PATH }
  & ctest . -V -C "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.no-exceptions.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  Write-Output "<Project>
  <PropertyGroup>
     <UseStructuredOutput>false</UseStructuredOutput>
  </PropertyGroup>
</Project>" > Directory.Build.props
  & cmake .. -G "$Env:CMAKE_GENERATOR" -A x64 "-DBUILD_SHARED_LIBS=OFF" "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE"  `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DCOMPILER_OPTION_DEFAULT_ENABLE_EXCEPTION=OFF" "-DVS_GLOBAL_VcpkgEnabled=OFF" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    # Some versions of MSVC has wrong dependencies. We ignore errors
    if (Test-Path "ignore-configure-error.txt") {
      exit 0
    }
    else {
      exit $LastExitCode
    }
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin"
  $TEST_BIN_PATH = Get-ChildItem -Recurse -Path bin -File "*.exe" | Foreach-object {echo $_.Directory.FullName} | Select-Object -First 1
  Get-ChildItem -Recurse -Path ../third_party/install/ -File "*.dll" | Foreach-object { Copy-Item -Force $_ -Destination $TEST_BIN_PATH }
  & ctest . -V -C "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "android.arm64.test" ) {
  # Android cross compiling on Windows host, see ci/cmake_android_wrapper.sh for the linux/macos version.
  # Prefer the latest NDK on CI runners, fallback to ANDROID_NDK (github windows runners set
  # ANDROID_NDK/ANDROID_NDK_HOME/ANDROID_NDK_ROOT to the LTS one)
  $ANDROID_NDK_ROOT = ""
  foreach ($ANDROID_NDK_CANDIDATE in @("$Env:ANDROID_NDK_LATEST_HOME", "$Env:ANDROID_NDK", "$Env:ANDROID_NDK_ROOT", "$Env:ANDROID_NDK_HOME")) {
    if ( [string]::IsNullOrEmpty($ANDROID_NDK_CANDIDATE) ) {
      continue
    }
    if ( Test-Path "$ANDROID_NDK_CANDIDATE/build/cmake/android.toolchain.cmake" ) {
      $ANDROID_NDK_ROOT = $ANDROID_NDK_CANDIDATE
      break
    }
  }
  if ( [string]::IsNullOrEmpty($ANDROID_NDK_ROOT) ) {
    Write-Output "Can not find Android NDK (checked ANDROID_NDK_LATEST_HOME, ANDROID_NDK, ANDROID_NDK_ROOT and ANDROID_NDK_HOME), dependency error."
    exit 1
  }
  Write-Output "Using Android NDK: $ANDROID_NDK_ROOT"

  $ANDROID_ABI = "arm64-v8a"
  $ANDROID_NATIVE_API_LEVEL = 24 # 64 bits must at least android-21, and libuv needs android-24(Android 7.0)
  $ANDROID_EXT_OPTIONS = @("-DANDROID_LD=lld")
  # The legacy toolchain file is deprecated since NDK 25 and removed in newer versions
  $ANDROID_NDK_MAJOR_VERSION = 0
  if ( Test-Path "$ANDROID_NDK_ROOT/source.properties" ) {
    foreach ($ANDROID_NDK_PROPERTY_LINE in Get-Content "$ANDROID_NDK_ROOT/source.properties") {
      if ( $ANDROID_NDK_PROPERTY_LINE -match '^Pkg\.Revision\s*=\s*(\d+)' ) {
        $ANDROID_NDK_MAJOR_VERSION = [int]$Matches[1]
        break
      }
    }
  }
  if ( $ANDROID_NDK_MAJOR_VERSION -ge 25 ) {
    $ANDROID_EXT_OPTIONS += "-DANDROID_USE_LEGACY_TOOLCHAIN_FILE=OFF"
  }

  Write-Output $args
  New-Item -Path "test/build_jobs_android" -ItemType "directory" -Force
  Set-Location "test/build_jobs_android"
  $WORKING_DIR = (Get-Location).Path
  New-Item -Path "build_jobs_arm64-v8a" -ItemType "directory" -Force
  Set-Location "build_jobs_arm64-v8a"
  # Use Ninja generator, the default Visual Studio generator can not drive the NDK clang toolchain.
  # Host tools (protoc, flatc, grpc plugins...) are still built by the host default generator.
  & cmake ../.. -G "Ninja" `
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo" `
    "-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" `
    "-DANDROID_PLATFORM=android-$ANDROID_NATIVE_API_LEVEL" "-DCMAKE_ANDROID_API=$ANDROID_NATIVE_API_LEVEL" `
    "-DANDROID_TOOLCHAIN=clang" "-DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang" `
    "-DANDROID_ABI=$ANDROID_ABI" "-DCMAKE_ANDROID_ARCH_ABI=$ANDROID_ABI" `
    "-DANDROID_STL=c++_shared" "-DCMAKE_ANDROID_STL_TYPE=c++_shared" `
    "-DANDROID_PIE=YES" `
    "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW" `
    "-DANDROID_SANITIZE=" `
    "-DCMAKE_C_STANDARD_LIBRARIES=-llog -lc" "-DCMAKE_CXX_STANDARD_LIBRARIES=-llog -lc" `
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR=$WORKING_DIR/build_jobs_host" `
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES" `
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON" `
    $ANDROID_EXT_OPTIONS $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.standalone-upb.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  Write-Output "<Project>
  <PropertyGroup>
     <UseStructuredOutput>false</UseStructuredOutput>
  </PropertyGroup>
</Project>" > Directory.Build.props
  & cmake ../upb -G "$Env:CMAKE_GENERATOR" -A x64 "-DBUILD_SHARED_LIBS=OFF" "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE" `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DVS_GLOBAL_VcpkgEnabled=OFF" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.vcpkg.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  # benchmark 1.7.0 has linking problems
  vcpkg install --triplet=x64-windows-static-md fmt zlib lz4 zstd libuv lua openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest civetweb prometheus-cpp mimalloc
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location -Verbose "test/build_jobs_dir"
  Write-Output "<Project>
  <PropertyGroup>
     <UseStructuredOutput>false</UseStructuredOutput>
  </PropertyGroup>
</Project>" > Directory.Build.props
  if(Test-Path "$ENV:VCPKG_INSTALLATION_ROOT/buildtrees") {
    Remove-Item -Recurse -Force "$ENV:VCPKG_INSTALLATION_ROOT/buildtrees"
  }
  if(Test-Path "$ENV:VCPKG_INSTALLATION_ROOT/packages") {
    Remove-Item -Recurse -Force "$ENV:VCPKG_INSTALLATION_ROOT/packages"
  }
  & cmake .. -G "$Env:CMAKE_GENERATOR" -A x64 "-DCMAKE_TOOLCHAIN_FILE=$ENV:VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake"   `
    -DVCPKG_TARGET_TRIPLET=x64-windows "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE" "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" `
    "-DATFRAMEWORK_USE_DYNAMIC_LIBRARY=ON" `
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin"
  $TEST_BIN_PATH = Get-ChildItem -Recurse -Path bin -File "*.exe" | Foreach-object {echo $_.Directory.FullName} | Select-Object -First 1
  Get-ChildItem -Recurse -Path ../third_party/install/ -File "*.dll" | Foreach-object { Copy-Item -Force $_ -Destination $TEST_BIN_PATH }
  & ctest . -V -C "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc2017.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 15 2017 Win64" "-DCMAKE_BUILD_TYPE=$Env:CI_BUILD_CONFIGURE_TYPE" "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" `
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON" "-DVS_GLOBAL_VcpkgEnabled=OFF" $ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS
  if ( $LastExitCode -ne 0 ) {
    if (Test-Path "CMakeFiles/CMakeConfigureLog.yaml") {
      Get-Content "CMakeFiles/CMakeConfigureLog.yaml"
    }
    elseif (Test-Path "CMakeFiles/CMakeError.log") {
      Get-Content "CMakeFiles/CMakeError.log"
    }
    exit $LastExitCode
  }
  & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    & cmake --build . -j --config "$Env:CI_BUILD_CONFIGURE_TYPE" --verbose
  }
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin"
  $TEST_BIN_PATH = Get-ChildItem -Recurse -Path bin -File "*.exe" | Foreach-object {echo $_.Directory.FullName} | Select-Object -First 1
  Get-ChildItem -Recurse -Path ../third_party/install/ -File "*.dll" | Foreach-object { Copy-Item -Force $_ -Destination $TEST_BIN_PATH }
  & ctest . -V -C "$Env:CI_BUILD_CONFIGURE_TYPE"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}

Set-Location $WORK_DIR
