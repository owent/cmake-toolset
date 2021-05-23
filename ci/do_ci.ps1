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
  $lastWinSDKVersion = $(Get-ChildItem $winSDKDir | Sort-Object -Property Name | Select-Object -Last 1).Name
  if (!(Test-Path Env:WindowsSDKVersion)) {
    $Env:WindowsSDKVersion = $lastWinSDKVersion
  }
  Write-Output "Window SDKs:(Latest: $lastWinSDKVersion)"
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
    "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=$lastWinSDKVersion"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
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
    "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=$lastWinSDKVersion"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
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
    -DVCPKG_TARGET_TRIPLET=x64-windows -DCMAKE_BUILD_TYPE=Release "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=$lastWinSDKVersion"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}
elseif ( $RUN_MODE -eq "msvc2017.test" ) {
  Invoke-Environment "call ""$vsInstallationPath/VC/Auxiliary/Build/vcvars64.bat"""
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 15 2017" -A x64 -DCMAKE_BUILD_TYPE=Release `
    "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=$lastWinSDKVersion"
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
  & cmake --build . -j || cmake --build .
  if ( $LastExitCode -ne 0 ) {
    exit $LastExitCode
  }
}

Set-Location $WORK_DIR
