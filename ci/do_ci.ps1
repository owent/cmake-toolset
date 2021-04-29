$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'

$OutputEncoding = [System.Text.UTF8Encoding]::new()

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$WORK_DIR = Get-Location

Set-Location "$SCRIPT_DIR/.."
$RUN_MODE = $args[0]

if ( $RUN_MODE -eq "msvc.static.test" ) {
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=OFF
  & cmake --build . -j || cmake --build .
}
elseif ( $RUN_MODE -eq "msvc.shared.test" ) {
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON
  & cmake --build . -j || cmake --build .
}
elseif ( $RUN_MODE -eq "msvc.vcpkg.test" ) {
  Write-Output $args
  vcpkg install --triplet=x64-windows fmt zlib lz4 zstd libuv openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest benchmark
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location -Verbose "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 16 2019" -A x64 -DCMAKE_TOOLCHAIN_FILE=$ENV:VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows
  & cmake --build . -j || cmake --build .
}
elseif ( $RUN_MODE -eq "msvc2017.test" ) {
  Write-Output $args
  New-Item -Path "test/build_jobs_dir" -ItemType "directory" -Force
  Set-Location "test/build_jobs_dir"
  & cmake .. -G "Visual Studio 15 2017" -A x64
  & cmake --build . -j || cmake --build .
}

Set-Location $WORK_DIR
