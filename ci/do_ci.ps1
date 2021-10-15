$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'

$OutputEncoding = [System.Text.UTF8Encoding]::new()

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$WORK_DIR = Get-Location

if ($IsWindows) {
  # See https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=cmd
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
}

Set-Location "$SCRIPT_DIR/.."
$RUN_MODE = $args[0]

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
}

if ( $RUN_MODE -eq "msvc.static.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib64" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib"
  & ctest . -V -C Release
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.shared.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release  `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib64" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib"
  & ctest . -V -C Release
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.no-rtti.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release  `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DCOMPILER_OPTION_DEFAULT_ENABLE_RTTI=OFF"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib64" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib"
  & ctest . -V -C Release
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.no-exceptions.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release  `
    "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"  `
    "-DCOMPILER_OPTION_DEFAULT_ENABLE_EXCEPTION=OFF"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib64" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib"
  & ctest . -V -C Release
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc.vcpkg.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  vcpkg install --triplet=x64-windows fmt zlib lz4 zstd libuv lua openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest benchmark civetweb prometheus-cpp
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location -Verbose "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 "-DCMAKE_TOOLCHAIN_FILE=$ENV:VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake"   `
    -DVCPKG_TARGET_TRIPLET=x64-windows -DCMAKE_BUILD_TYPE=Release "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib64" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib"
  & ctest . -V -C Release
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc2017.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 15 2017 Win64" -DCMAKE_BUILD_TYPE=Release "-DCMAKE_SYSTEM_VERSION=$selectWinSDKVersion" "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  $THIRD_PARTY_PREBUILT_PATH = $(Get-ChildItem ../third_party/install/).FullName
  $Env:PATH = $Env:PATH + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/bin" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib64" + [IO.Path]::PathSeparator + "$THIRD_PARTY_PREBUILT_PATH/lib"
  & ctest . -V -C Release
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}

Set-Location $WORK_DIR
