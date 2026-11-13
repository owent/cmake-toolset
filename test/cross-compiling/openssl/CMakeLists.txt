cmake_minimum_required(VERSION 3.16)
project(cmake-toolset-openssl-cross-environment-test LANGUAGES C CXX)

set(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${CMAKE_CURRENT_LIST_DIR}/../../..")
set(PROJECT_THIRD_PARTY_PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/packages")
set(PROJECT_THIRD_PARTY_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/prefix")
set(PROJECT_THIRD_PARTY_HOST_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/host-prefix")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")

# Exercise the port's Windows -> Unix script generation without downloading or compiling OpenSSL.
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
# Model the compiler properties consumed by script generation; the fixture does not compile target code.
set(CMAKE_C_COMPILER_ID Clang)
set(CMAKE_CXX_COMPILER_ID Clang)
set(CMAKE_C_COMPILER_TARGET x86_64-unknown-linux-gnu)
set(PROJECT_PREBUILT_PLATFORM_NAME linux-x86_64-clang-20)
set(CMAKE_INSTALL_RPATH "$ORIGIN" "$ORIGIN/../lib64" "$ORIGIN/../lib")
set(ENV{CFLAGS} "")
set(ENV{CXXFLAGS} "")
set(WIN32 FALSE)
set(UNIX TRUE)
set(MSVC FALSE)
set(CMAKE_DISABLE_FIND_PACKAGE_OpenSSL TRUE)
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS no-tests)
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/build")
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/source")
file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}"
     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}")
file(
  WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/Configure"
  [=[
use strict;
use warnings;
use IPC::Cmd qw(can_run);
use ExtUtils::MakeMaker;
use Locale::Maketext::Simple;
use Pod::Usage;
use Text::ParseWords qw(shellwords);
die "IPC::Cmd cannot locate perl" unless can_run('perl');
for my $module (qw(ExtUtils/MakeMaker.pm Locale/Maketext/Simple.pm Pod/Usage.pm)) {
    die "$module did not load from the copied stubs" unless $INC{$module} =~ m{^perl-stub/};
}
die "OpenSSL lost the Clang cross target" unless $ENV{CFLAGS} =~ /(?:^|\s)--target=x86_64-unknown-linux-gnu(?:\s|$)/;
open my $result, '>', 'configured' or die $!;
print $result "ok\n";
open my $makefile, '>', 'Makefile' or die $!;
my $ldflags = join(' ', shellwords($ENV{LDFLAGS}));
print $makefile "all install_sw install_ssldirs:\n\t/usr/bin/perl ../source/check-link.pl $ldflags\n";
]=])
file(
  WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/check-link.pl"
  [=[
use strict;
use warnings;
die "OpenSSL lost its loader-relative RPATH" unless grep {
    $_ eq '-Wl,-rpath,$ORIGIN:$ORIGIN/../lib64:$ORIGIN/../lib'
} @ARGV;
open my $result, '>', 'linked' or die $!;
print $result "ok\n";
]=])
file(REMOVE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/configured"
     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/linked"
     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/Makefile")

function(project_git_clone_repository)
  # The fixture provides the source; all environment generation and Perl invocation use the real port.
endfunction()

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/ssl/openssl/openssl.cmake")
if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/configured")
  message(FATAL_ERROR "OpenSSL Configure failed to use the generated cross-build environment")
endif()
if(NOT CMAKE_INSTALL_RPATH STREQUAL "$ORIGIN;$ORIGIN/../lib64;$ORIGIN/../lib")
  message(FATAL_ERROR "OpenSSL changed the parent project's install RPATH")
endif()
if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/linked")
  message(FATAL_ERROR "OpenSSL's generated Makefile did not preserve the target RPATH arguments")
endif()
