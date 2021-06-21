cmake_minimum_required(VERSION 3.16)
cmake_policy(SET CMP0022 NEW)
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0067 NEW)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0091 NEW)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19.0")
  cmake_policy(SET CMP0111 NEW)
endif()

set(LIBSODIUM_SOURCE_DIR
    "${CMAKE_CURRENT_LIST_DIR}"
    CACHE PATH "Source path of libsodium")

#[===[.md:
# See https://github.com/microsoft/vcpkg/blob/master/ports/libsodium/CMakeLists.txt
# Replace:
#  PROJECT_SOURCE_DIR->LIBSODIUM_SOURCE_DIR
#  CMAKE_CURRENT_LIST_DIR->LIBSODIUM_SOURCE_DIR
#]===]

include(CheckCSourceRuns)

file(STRINGS "${LIBSODIUM_SOURCE_DIR}/configure.ac" config_ac_contents)

foreach(line ${config_ac_contents})
  if(line MATCHES "AC_INIT\\(\\[libsodium\\],\\[([0-9.]+)\\],")
    set(VERSION ${CMAKE_MATCH_1})
  elseif(line MATCHES "SODIUM_LIBRARY_VERSION_(MAJOR|MINOR)=([0-9]+)")
    set(SODIUM_LIBRARY_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
  endif()
endforeach()

message("VERSION: ${VERSION}")
message("SODIUM_LIBRARY_VERSION_MAJOR: ${SODIUM_LIBRARY_VERSION_MAJOR}")
message("SODIUM_LIBRARY_VERSION_MINOR: ${SODIUM_LIBRARY_VERSION_MINOR}")

project(
  libsodium
  VERSION ${VERSION}
  LANGUAGES C ASM)

include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CMakePackageConfigHelpers)
include(CTest)
include(GNUInstallDirs)
include(TestBigEndian)

set(CMAKE_C_STANDARD 99)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

option(BUILD_SHARED_LIBS "Build shared library" ${BUILD_SHARED_LIBS})
option(ENABLE_SSP "Compile with -fstack-protector" ON)
option(ENABLE_PIE "Compile with -fPIE" ON)
option(ENABLE_BLOCKING_RANDOM "Enable blocking random" OFF)
option(ENABLE_MINIMAL "Only compile the minimum set of functions required for the high-level API" OFF)
option(ENABLE_PTHREADS "Use pthreads library" ON)
option(ENABLE_RETPOLINE "Use return trampolines for indirect calls" OFF)
option(ENABLE_NATIVE_OPTIMIZATIONS
       "Optimize for the native CPU - The resulting library will be faster but not portable" OFF)

if(ENABLE_MINIMAL)
  set(SODIUM_LIBRARY_MINIMAL_DEF "#define SODIUM_LIBRARY_MINIMAL 1")
endif()

configure_file(src/libsodium/include/sodium/version.h.in ${CMAKE_BINARY_DIR}/sodium/version.h)

add_library(${PROJECT_NAME})

set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" OUTPUT_NAME "lib${PROJECT_NAME}")

if(MSVC)

  target_include_directories(
    ${PROJECT_NAME} PRIVATE $<BUILD_INTERFACE:${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium>
                            $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/sodium>)

  enable_language(RC)

  # see libsodium.vcxproj for reference - omitted "<ClInclude Include="src\libsodium\include\sodium\version.h" />" in
  # favour of "${CMAKE_BINARY_DIR}/sodium/version.h"
  file(GLOB_RECURSE sodium_headers ${CMAKE_BINARY_DIR}/sodium/version.h ${LIBSODIUM_SOURCE_DIR}/builds/msvc/resource.h
       ${LIBSODIUM_SOURCE_DIR}/src/libsodium/*.h)

  file(GLOB_RECURSE sodium_sources ${LIBSODIUM_SOURCE_DIR}/builds/msvc/resource.rc
       ${LIBSODIUM_SOURCE_DIR}/src/libsodium/*.c)

  target_sources(${PROJECT_NAME} PRIVATE ${sodium_headers} ${sodium_sources})

  target_compile_options(
    ${PROJECT_NAME}
    PRIVATE /D_CONSOLE
            /D_CRT_SECURE_NO_WARNINGS
            /DCPU_UNALIGNED_ACCESS=1
            /MP
            /Dinline=__inline
            /wd4068 # Unknown pragma
            /wd4197
            /wd4244 # Macro redefinition
  )

  target_link_libraries(${PROJECT_NAME} PUBLIC advapi32)

else()

  # use interface libs to track common flags and definitions across all targets
  add_library(${PROJECT_NAME}_config_private INTERFACE)
  add_library(${PROJECT_NAME}_config_public INTERFACE)

  # use interface libs to track special flags only required for certain objects
  add_library(${PROJECT_NAME}_aesni_config INTERFACE)
  add_library(${PROJECT_NAME}_avx_config INTERFACE)
  add_library(${PROJECT_NAME}_avx2_config INTERFACE)
  add_library(${PROJECT_NAME}_avx512f_config INTERFACE)
  add_library(${PROJECT_NAME}_mmx_config INTERFACE)
  add_library(${PROJECT_NAME}_pclmul_config INTERFACE)
  add_library(${PROJECT_NAME}_rdrand_config INTERFACE)
  add_library(${PROJECT_NAME}_sse2_config INTERFACE)
  add_library(${PROJECT_NAME}_sse3_config INTERFACE)
  add_library(${PROJECT_NAME}_sse41_config INTERFACE)
  add_library(${PROJECT_NAME}_ssse3_config INTERFACE)

  target_include_directories(
    ${PROJECT_NAME}_config_private INTERFACE $<BUILD_INTERFACE:${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium>
                                             $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/sodium>)

  target_compile_options(
    ${PROJECT_NAME}_config_private
    INTERFACE -flax-vector-conversions
              -fvisibility=hidden
              -fwrapv
              -Wall
              -Wextra
              -Wbad-function-cast
              -Wcast-qual
              # -Wdiv-by-zero -Wduplicated-branches -Wduplicated-cond
              -Wfloat-equal
              -Wformat=2
              -Wlogical-op
              -Wmaybe-uninitialized
              # -Wmisleading-indentation
              -Wmissing-declarations
              -Wmissing-prototypes
              -Wnested-externs
              # -Wno-type-limits -Wno-unknown-pragmas
              -Wnormalized=id
              # -Wnull-dereference
              -Wold-style-declaration
              -Wpointer-arith
              -Wredundant-decls
              # -Wrestrict -Wsometimes-uninitialized
              -Wstrict-prototypes
              -Wswitch-enum
              # -Wvariable-decl
              -Wwrite-strings)

  if(NOT MINGW)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -fPIC -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack)
  endif()

  if(MINGW)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -fno-asynchronous-unwind-tables)
    target_link_options(${PROJECT_NAME}_config_private INTERFACE -Wl,--dynamicbase -Wl,--high-entropy-va -Wl,--nxcompat)
  endif()

  if(CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -Wno-unknown-warning-option -Wshorten-64-to-32)
  endif()

  # see configure.ac for reference
  if(ENABLE_BLOCKING_RANDOM)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE USE_BLOCKING_RANDOM)
  endif()

  if(ENABLE_PTHREADS)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_PTHREAD)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -ftls-model=local-dynamic)
    target_compile_options(${PROJECT_NAME}_config_public INTERFACE -pthread)
  endif()

  if(ENABLE_SSP AND NOT MINGW)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -fstack-protector-all)
  endif()

  if(ENABLE_PIE AND NOT MINGW)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -fPIE)
  endif()

  if(ENABLE_RETPOLINE)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -mindirect-branch=thunk-inline
                                                                    -mindirect-branch-register)
  endif()

  if(ENABLE_NATIVE_OPTIMIZATIONS)
    target_compile_options(${PROJECT_NAME}_config_private INTERFACE -ftree-vectorize -ftree-slp-vectorize
                                                                    -fomit-frame-pointer -march=native)
  endif()

  check_include_file(sys/mman.h HAVE_SYS_MMAN_H)
  if(HAVE_SYS_MMAN_H)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_SYS_MMAN_H)
  endif()

  macro(sodium_check_func func var)
    check_function_exists(${func} ${var})
    if(${var})
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE ${var}=1)
    endif()
  endmacro()

  sodium_check_func(arc4random HAVE_SAFE_ARC4RANDOM)
  sodium_check_func(mmap HAVE_MMAP)
  sodium_check_func(mlock HAVE_MLOCK)
  sodium_check_func(madvise HAVE_MADVISE)
  sodium_check_func(mprotect HAVE_MPROTECT)
  sodium_check_func(memset_s HAVE_MEMSET_S)
  sodium_check_func(explicit_bzero HAVE_EXPLICIT_BZERO)
  sodium_check_func(explicit_memset HAVE_EXPLICIT_MEMSET)
  sodium_check_func(nanosleep HAVE_NANOSLEEP)
  sodium_check_func(posix_memalign HAVE_POSIX_MEMALIGN)
  sodium_check_func(getpid HAVE_GETPID)

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    check_c_source_runs(
      "
            #pragma GCC target(\"mmx\")
            #include <mmintrin.h>
            int main(void)
            {
            __m64 x = _mm_setzero_si64();
            }
            "
      HAVE_MMINTRIN_H)

    if(HAVE_MMINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_MMINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_mmx_config INTERFACE -mmmx)
    endif()

    check_c_source_runs(
      "
            #pragma GCC target(\"sse2\")
            #ifndef __SSE2__
            # define __SSE2__
            #endif

            #include <emmintrin.h>
            int main(void) {
            __m128d x = _mm_setzero_pd();
            __m128i z = _mm_srli_epi64(_mm_setzero_si128(), 26);
            }
            "
      HAVE_EMMINTRIN_H)

    if(HAVE_EMMINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_EMMINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_sse2_config INTERFACE -msse2)
    endif()

    check_c_source_runs(
      "
            #pragma GCC target(\"sse3\")
            #include <pmmintrin.h>
            int main(void) {
            __m128 x = _mm_addsub_ps(_mm_cvtpd_ps(_mm_setzero_pd()), _mm_cvtpd_ps(_mm_setzero_pd()));
            }
            "
      HAVE_PMMINTRIN_H)

    if(HAVE_PMMINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_PMMINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_sse3_config INTERFACE -msse3)
    endif()

    check_c_source_runs(
      "
            #pragma GCC target(\"ssse3\")
            #include <tmmintrin.h>
            int main(void) {
            __m64 x = _mm_abs_pi32(_m_from_int(0));
            }
            "
      HAVE_TMMINTRIN_H)

    if(HAVE_TMMINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_TMMINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_ssse3_config INTERFACE -mssse3)
    endif()

    check_c_source_runs(
      "
            #pragma GCC target(\"sse4.1\")
            #include <smmintrin.h>
            int main(void) {
            __m128i x = _mm_minpos_epu16(_mm_setzero_si128());
            }
            "
      HAVE_SMMINTRIN_H)

    if(HAVE_SMMINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_SMMINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_sse41_config INTERFACE -msse4.1)
    endif()

    check_c_source_runs(
      "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AVX opcodes
            #endif
            #pragma GCC target(\"avx\")
            #include <immintrin.h>
            int main(void) {
            _mm256_zeroall();
            }
            "
      HAVE_AVXINTRIN_H)

    if(HAVE_AVXINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_AVXINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_avx_config INTERFACE -mavx)
    endif()

    check_c_source_runs(
      "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AVX2 opcodes
            #endif
            #pragma GCC target(\"avx2\")
            #include <immintrin.h>
            int main(void) {
            __m256 x = _mm256_set1_ps(3.14);
            __m256 y = _mm256_permutevar8x32_ps(x, _mm256_set1_epi32(42));
            return _mm256_movemask_ps(_mm256_cmp_ps(x, y, _CMP_NEQ_OQ));
            }
            "
      HAVE_AVX2INTRIN_H)

    if(HAVE_AVX2INTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_AVX2INTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_avx2_config INTERFACE -mavx2)

      check_c_source_runs(
        "
                #ifdef __native_client__
                # error NativeClient detected - Avoiding AVX2 opcodes
                #endif
                #pragma GCC target(\"avx2\")
                #include <immintrin.h>
                int main(void) {
                __m256i y = _mm256_broadcastsi128_si256(_mm_setzero_si128());
                }
                "
        _mm256_broadcastsi128_si256_DEFINED)

      if(NOT _mm256_broadcastsi128_si256_DEFINED)
        target_compile_definitions(${PROJECT_NAME}_config_private
                                   INTERFACE _mm256_broadcastsi128_si256=_mm_broadcastsi128_si256)
      endif()
    endif()

    check_c_source_runs(
      "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AVX512F opcodes
            #endif
            #pragma GCC target(\"avx512f\")
            #include <immintrin.h>

            #ifndef __AVX512F__
            # error No AVX512 support
            #elif defined(__clang__)
            # if __clang_major__ < 4
            #  error Compiler AVX512 support may be broken
            # endif
            #elif defined(__GNUC__)
            # if __GNUC__ < 6
            #  error Compiler AVX512 support may be broken
            # endif
            #endif

            int main(void) {
            __m512i x = _mm512_setzero_epi32();
            __m512i y = _mm512_permutexvar_epi64(_mm512_setr_epi64(0, 1, 4, 5, 2, 3, 6, 7), x);
            }
            "
      HAVE_AVX512FINTRIN_H)

    if(HAVE_AVX512FINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_AVX512FINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_avx512f_config INTERFACE -mavx512f)
    endif()

    check_c_source_runs(
      "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AESNI opcodes
            #endif
            #pragma GCC target(\"aes\")
            #pragma GCC target(\"pclmul\")
            #include <wmmintrin.h>
            int main(void) {
            __m128i x = _mm_aesimc_si128(_mm_setzero_si128());
            __m128i y = _mm_clmulepi64_si128(_mm_setzero_si128(), _mm_setzero_si128(), 0);
            }
            "
      HAVE_WMMINTRIN_H)

    if(HAVE_WMMINTRIN_H)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_WMMINTRIN_H=1)
      target_compile_options(${PROJECT_NAME}_aesni_config INTERFACE -maes)
      target_compile_options(${PROJECT_NAME}_pclmul_config INTERFACE -mpclmul)
    endif()

    check_c_source_runs(
      "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding RDRAND opcodes
            #endif
            #pragma GCC target(\"rdrnd\")
            #include <immintrin.h>
            int main(void) {
            unsigned long long x;
            _rdrand64_step(&x);
            }
            "
      HAVE_RDRAND)

    if(HAVE_RDRAND)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_RDRAND=1)
      target_compile_options(${PROJECT_NAME}_rdrand_config INTERFACE -mrdrnd)
    endif()

    check_c_source_runs(
      "
            #include <intrin.h>
            int main(void) {
            (void) _xgetbv(0);
            }
            "
      HAVE__XGETBV)

    if(HAVE__XGETBV)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE__XGETBV=1)
    endif()

    check_c_source_runs(
      "
            int main(void) {
            int a = 42;
            int *pnt = &a;
            __asm__ __volatile__ (\"\" : : \"r\"(pnt) : \"memory\");
            }
            "
      HAVE_INLINE_ASM)

    if(HAVE_INLINE_ASM)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_INLINE_ASM=1)
    endif()

    check_c_source_runs(
      "
            int main(void) {
            #if defined(__amd64) || defined(__amd64__) || defined(__x86_64__)
            # if defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__) || defined(_WIN32) || defined(_WIN64)
            #  error Windows x86_64 calling conventions are not supported yet
            # endif
            /* neat */
            #else
            # error !x86_64
            #endif
            unsigned char i = 0, o = 0, t;
            __asm__ __volatile__ (\"pxor %%xmm12, %%xmm6 \n\"
                \"movb (%[i]), %[t] \n\"
                \"addb %[t], (%[o]) \n\"
                : [t] \"=&r\"(t)
                : [o] \"D\"(&o), [i] \"S\"(&i)
                : \"memory\", \"flags\", \"cc\");
            }
            "
      HAVE_AMD64_ASM)

    if(HAVE_AMD64_ASM)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_AMD64_ASM=1)
    endif()

    check_c_source_runs(
      "
            int main(void) {
            #if defined(__amd64) || defined(__amd64__) || defined(__x86_64__)
            # if defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__) || defined(_WIN32) || defined(_WIN64)
            #  error Windows x86_64 calling conventions are not supported yet
            # endif
            /* neat */
            #else
            # error !x86_64
            #endif
            __asm__ __volatile__ (\"vpunpcklqdq %xmm0,%xmm13,%xmm0\");
            }
            "
      HAVE_AVX_ASM)

    if(HAVE_AVX_ASM)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_AVX_ASM=1)
    endif()

    check_c_source_runs(
      "
            #if !defined(__clang__) && !defined(__GNUC__) && !defined(__SIZEOF_INT128__)
            # error mode(TI) is a gcc extension, and __int128 is not available
            #endif
            #if defined(__clang__) && !defined(__x86_64__) && !defined(__aarch64__)
            # error clang does not properly handle the 128-bit type on 32-bit systems
            #endif
            #ifndef NATIVE_LITTLE_ENDIAN
            # error libsodium currently expects a little endian CPU for the 128-bit type
            #endif
            #ifdef __EMSCRIPTEN__
            # error emscripten currently doesn't support some operations on integers larger than 64 bits
            #endif
            #include <stddef.h>
            #include <stdint.h>
            #if defined(__SIZEOF_INT128__)
            typedef unsigned __int128 uint128_t;
            #else
            typedef unsigned uint128_t __attribute__((mode(TI)));
            #endif
            void fcontract(uint128_t *t) {
            *t += 0x8000000000000 - 1;
            *t *= *t;
            *t >>= 84;
            }
            int main(void) {
            (void) fcontract;
            }
            "
      HAVE_TI_MODE)

    if(HAVE_TI_MODE)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_TI_MODE=1)
    endif()

    check_c_source_runs(
      "
            int main(void) {
            unsigned int cpu_info[4];
            __asm__ __volatile__ (\"xchgl %%ebx, %k1; cpuid; xchgl %%ebx, %k1\" :
                \"=a\" (cpu_info[0]), \"=&r\" (cpu_info[1]),
                \"=c\" (cpu_info[2]), \"=d\" (cpu_info[3]) :
                \"0\" (0U), \"2\" (0U));
            }
            "
      HAVE_CPUID)

    if(HAVE_CPUID)
      target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_CPUID=1)
    endif()
  endif()

  check_c_source_runs(
    "
        #if !defined(__ELF__) && !defined(__APPLE_CC__)
        # error Support for weak symbols may not be available
        #endif
        __attribute__((weak)) void __dummy(void *x) { }
        void f(void *x) { __dummy(x); }
        int main(void) {}
        "
    HAVE_WEAK_SYMBOLS)

  if(HAVE_WEAK_SYMBOLS)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_WEAK_SYMBOLS=1)
  endif()

  check_c_source_runs(
    "
        int main(void) {
        static volatile int _sodium_lock;
        __sync_lock_test_and_set(&_sodium_lock, 1);
        __sync_lock_release(&_sodium_lock);
        }
        "
    HAVE_ATOMIC_OPS)

  if(HAVE_ATOMIC_OPS)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE HAVE_ATOMIC_OPS=1)
  endif()

  check_c_source_runs(
    "
        #include <limits.h>
        #include <stdint.h>
        int main(void) {
        (void) SIZE_MAX;
        (void) UINT64_MAX;
        }
        "
    STDC_LIMIT_MACROS_REQUIRED)

  if(STDC_LIMIT_MACROS_REQUIRED)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE __STDC_LIMIT_MACROS __STDC_CONSTANT_MACROS)
  endif()

  # include/sodium/private/common.h
  target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE CONFIGURED=1)

  test_big_endian(IS_BIG_ENDIAN)

  if(IS_BIG_ENDIAN)
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE NATIVE_BIG_ENDIAN)
  else()
    target_compile_definitions(${PROJECT_NAME}_config_private INTERFACE NATIVE_LITTLE_ENDIAN)
  endif()

  # see src/libsodium/Makefile.am for reference
  target_sources(
    ${PROJECT_NAME}
    PRIVATE ${CMAKE_BINARY_DIR}/sodium/version.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_aead/chacha20poly1305/sodium/aead_chacha20poly1305.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_aead/xchacha20poly1305/sodium/aead_xchacha20poly1305.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_auth/crypto_auth.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_auth/hmacsha256/auth_hmacsha256.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_auth/hmacsha512/auth_hmacsha512.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_auth/hmacsha512256/auth_hmacsha512256.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_box/crypto_box.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_box/crypto_box_easy.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_box/crypto_box_seal.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_box/curve25519xsalsa20poly1305/box_curve25519xsalsa20poly1305.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/ed25519_ref10.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/hchacha20/core_hchacha20.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/hsalsa20/ref2/core_hsalsa20_ref2.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/hsalsa20/core_hsalsa20.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/salsa/ref/core_salsa_ref.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/crypto_generichash.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/generichash_blake2.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-ref.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-load-sse2.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-load-sse41.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-load-avx2.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-ref.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/generichash_blake2b.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_hash/crypto_hash.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_hash/sha256/hash_sha256.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_hash/sha256/cp/hash_sha256_cp.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_hash/sha512/hash_sha512.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_hash/sha512/cp/hash_sha512_cp.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_kdf/blake2b/kdf_blake2b.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_kdf/crypto_kdf.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_kx/crypto_kx.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/crypto_onetimeauth.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/onetimeauth_poly1305.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/onetimeauth_poly1305.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/donna/poly1305_donna.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/donna/poly1305_donna32.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/donna/poly1305_donna64.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/donna/poly1305_donna.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-core.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-core.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-encoding.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-encoding.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-fill-block-ref.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/blake2b-long.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/blake2b-long.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/blamka-round-ref.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/pwhash_argon2i.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/pwhash_argon2id.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/crypto_pwhash.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/crypto_scalarmult.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/ref10/x25519_ref10.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/ref10/x25519_ref10.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/scalarmult_curve25519.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/scalarmult_curve25519.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_secretbox/crypto_secretbox.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_secretbox/crypto_secretbox_easy.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_secretbox/xsalsa20poly1305/secretbox_xsalsa20poly1305.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_secretstream/xchacha20poly1305/secretstream_xchacha20poly1305.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_shorthash/crypto_shorthash.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_shorthash/siphash24/shorthash_siphash24.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_shorthash/siphash24/ref/shorthash_siphash24_ref.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_shorthash/siphash24/ref/shorthash_siphash_ref.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/crypto_sign.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/ed25519/sign_ed25519.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/ed25519/ref10/keypair.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/ed25519/ref10/open.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/ed25519/ref10/sign.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/ed25519/ref10/sign_ed25519_ref10.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/stream_chacha20.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/stream_chacha20.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/ref/chacha20_ref.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/ref/chacha20_ref.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/crypto_stream.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/stream_salsa20.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/stream_salsa20.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/xsalsa20/stream_xsalsa20.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_verify/sodium/verify.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/chacha20_ietf_ext.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/common.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/ed25519_ref10.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/implementations.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/mutex.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/sse2_64_32.h
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/randombytes/randombytes.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/sodium/codecs.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/sodium/core.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/sodium/runtime.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/sodium/utils.c
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/sodium/version.c)

  if(HAVE_TI_MODE)
    target_sources(
      ${PROJECT_NAME}
      PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_51/base.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_51/base2.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_51/constants.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_51/fe.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/ed25519_ref10_fe_51.h)
  else()
    target_sources(
      ${PROJECT_NAME}
      PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_25_5/base.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_25_5/base2.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_25_5/constants.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/ref10/fe_25_5/fe.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/private/ed25519_ref10_fe_25_5.h)
  endif()

  if(HAVE_AMD64_ASM)
    target_sources(
      ${PROJECT_NAME}
      PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6/salsa20_xmm6-asm.S
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6/salsa20_xmm6.c
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6/salsa20_xmm6.h)
  else()
    target_sources(
      ${PROJECT_NAME} PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/ref/salsa20_ref.c
                              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/ref/salsa20_ref.h)
  endif()

  target_sources(
    ${PROJECT_NAME}
    PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/consts.S
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51_mul.S
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51_nsquare.S
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51_pack.S
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/ladder.S
            ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/ladder_base.S)

  if(HAVE_AVX_ASM)
    target_sources(
      ${PROJECT_NAME}
      PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/consts_namespace.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/curve25519_sandy2x.c
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/curve25519_sandy2x.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51_invert.c
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51_namespace.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe_frombytes_sandy2x.c
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/ladder.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/ladder_namespace.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/curve25519/sandy2x/sandy2x.S)
  endif()

  if(NOT ENABLE_MINIMAL)
    target_sources(
      ${PROJECT_NAME}
      PRIVATE
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_box/curve25519xchacha20poly1305/box_curve25519xchacha20poly1305.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_box/curve25519xchacha20poly1305/box_seal_curve25519xchacha20poly1305.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/core_ed25519.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_core/ed25519/core_ristretto255.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/crypto_scrypt-common.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/crypto_scrypt.h
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/scrypt_platform.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/pbkdf2-sha256.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/pbkdf2-sha256.h
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/pwhash_scryptsalsa208sha256.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/nosse/pwhash_scryptsalsa208sha256_nosse.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/ed25519/ref10/scalarmult_ed25519_ref10.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_scalarmult/ristretto255/ref10/scalarmult_ristretto255_ref10.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_secretbox/xchacha20poly1305/secretbox_xchacha20poly1305.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_shorthash/siphash24/shorthash_siphashx24.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_shorthash/siphash24/ref/shorthash_siphashx24_ref.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_sign/ed25519/ref10/obsolete.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa2012/ref/stream_salsa2012_ref.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa2012/stream_salsa2012.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa208/ref/stream_salsa208_ref.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa208/stream_salsa208.c
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/xchacha20/stream_xchacha20.c)
  endif()

  add_library(
    ${PROJECT_NAME}_rdrand OBJECT
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/randombytes/internal/randombytes_internal_random.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/randombytes/sysrandom/randombytes_sysrandom.c)

  target_link_libraries(${PROJECT_NAME}_rdrand PRIVATE ${PROJECT_NAME}_rdrand_config ${PROJECT_NAME}_config_public
                                                       ${PROJECT_NAME}_config_private)

  add_library(${PROJECT_NAME}_aesni OBJECT
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_aead/aes256gcm/aesni/aead_aes256gcm_aesni.c)

  target_link_libraries(
    ${PROJECT_NAME}_aesni
    PRIVATE ${PROJECT_NAME}_config_public ${PROJECT_NAME}_config_private ${PROJECT_NAME}_sse2_config
            ${PROJECT_NAME}_ssse3_config ${PROJECT_NAME}_aesni_config ${PROJECT_NAME}_pclmul_config)

  add_library(
    ${PROJECT_NAME}_sse2 OBJECT ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/sse2/poly1305_sse2.c
                                ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_onetimeauth/poly1305/sse2/poly1305_sse2.h)

  if(NOT ENABLE_MINIMAL)
    target_sources(
      ${PROJECT_NAME}_sse2
      PRIVATE
        ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/scryptsalsa208sha256/sse/pwhash_scryptsalsa208sha256_sse.c)
  endif()

  if(NOT HAVE_AMD64_ASM)
    target_sources(
      ${PROJECT_NAME}_sse2
      PRIVATE ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/salsa20_xmm6int-sse2.c
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/salsa20_xmm6int-sse2.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u0.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u1.h
              ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u4.h)
  endif()

  target_link_libraries(${PROJECT_NAME}_sse2 PRIVATE ${PROJECT_NAME}_config_public ${PROJECT_NAME}_config_private
                                                     ${PROJECT_NAME}_sse2_config)

  add_library(
    ${PROJECT_NAME}_ssse3 OBJECT
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-ssse3.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-ssse3.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-fill-block-ssse3.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/blamka-round-ssse3.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/chacha20_dolbeau-ssse3.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/chacha20_dolbeau-ssse3.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/u0.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/u1.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/u4.h)

  target_link_libraries(${PROJECT_NAME}_ssse3 PRIVATE ${PROJECT_NAME}_config_public ${PROJECT_NAME}_config_private
                                                      ${PROJECT_NAME}_sse2_config ${PROJECT_NAME}_ssse3_config)

  add_library(
    ${PROJECT_NAME}_sse41 OBJECT
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-sse41.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-sse41.h)

  target_link_libraries(
    ${PROJECT_NAME}_sse41 PRIVATE ${PROJECT_NAME}_config_public ${PROJECT_NAME}_config_private
                                  ${PROJECT_NAME}_sse2_config ${PROJECT_NAME}_ssse3_config ${PROJECT_NAME}_sse41_config)

  add_library(
    ${PROJECT_NAME}_avx2 OBJECT
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-avx2.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-avx2.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-fill-block-avx2.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/blamka-round-avx2.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/chacha20_dolbeau-avx2.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/chacha20_dolbeau-avx2.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/chacha20/dolbeau/u8.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/salsa20_xmm6int-avx2.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/salsa20_xmm6int-avx2.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u0.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u1.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u4.h
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_stream/salsa20/xmm6int/u8.h)

  target_link_libraries(
    ${PROJECT_NAME}_avx2
    PRIVATE ${PROJECT_NAME}_config_public
            ${PROJECT_NAME}_config_private
            ${PROJECT_NAME}_sse2_config
            ${PROJECT_NAME}_ssse3_config
            ${PROJECT_NAME}_sse41_config
            ${PROJECT_NAME}_avx_config
            ${PROJECT_NAME}_avx2_config)

  add_library(
    ${PROJECT_NAME}_avx512f OBJECT
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/argon2-fill-block-avx512f.c
    ${LIBSODIUM_SOURCE_DIR}/src/libsodium/crypto_pwhash/argon2/blamka-round-avx512f.h)

  target_link_libraries(
    ${PROJECT_NAME}_avx512f
    PRIVATE ${PROJECT_NAME}_config_public
            ${PROJECT_NAME}_config_private
            ${PROJECT_NAME}_sse2_config
            ${PROJECT_NAME}_ssse3_config
            ${PROJECT_NAME}_sse41_config
            ${PROJECT_NAME}_avx_config
            ${PROJECT_NAME}_avx2_config
            ${PROJECT_NAME}_avx512f_config)

  target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE "$<BUILD_INTERFACE:${PROJECT_NAME}_rdrand>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_aesni>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_sse2>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_ssse3>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_sse41>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_avx2>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_avx512f>"
            "$<BUILD_INTERFACE:${PROJECT_NAME}_config_private>"
    PUBLIC ${PROJECT_NAME}_config_public)

endif()

if(BUILD_SHARED_LIBS)
  if(MSVC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE SODIUM_DLL_EXPORT)
  endif()
else()
  if(MSVC)
    target_compile_definitions(${PROJECT_NAME} PUBLIC SODIUM_STATIC)
  else()
    target_compile_definitions(${PROJECT_NAME}_config_public INTERFACE SODIUM_STATIC)
  endif()
endif()

if(BUILD_TESTING)
  enable_testing()

  file(GLOB sodium_test_sources ${LIBSODIUM_SOURCE_DIR}/test/default/*.c)

  foreach(test_src ${sodium_test_sources})
    get_filename_component(test_name ${test_src} NAME_WE)

    add_executable(${test_name} ${test_src})

    if(MSVC)
      target_compile_definitions(${test_name} PRIVATE _CRT_SECURE_NO_WARNINGS)
    endif()

    target_include_directories(
      ${test_name}
      PRIVATE $<BUILD_INTERFACE:${LIBSODIUM_SOURCE_DIR}/src/libsodium/include>
              $<BUILD_INTERFACE:${LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium>
              $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}> $<BUILD_INTERFACE:${LIBSODIUM_SOURCE_DIR}/test/quirks>)

    target_link_libraries(${test_name} PRIVATE ${PROJECT_NAME})

    add_custom_command(
      TARGET ${test_name}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different "${LIBSODIUM_SOURCE_DIR}/test/default/${test_name}.exp"
              $<TARGET_FILE_DIR:${test_name}>)

    add_test(
      NAME ${test_name}
      COMMAND ${test_name}
      WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>)
  endforeach()
endif()

install(
  DIRECTORY src/libsodium/include/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  USE_SOURCE_PERMISSIONS
  PATTERN "*.h"
  PATTERN "*.h.in" EXCLUDE
  REGEX "private($|/)" EXCLUDE)

install(FILES ${CMAKE_BINARY_DIR}/sodium/version.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/sodium")

if(MSVC)
  install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
else()
  install(
    TARGETS ${PROJECT_NAME} ${PROJECT_NAME}_config_public
    EXPORT ${PROJECT_NAME}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
endif()

install(
  EXPORT ${PROJECT_NAME}-targets
  FILE ${PROJECT_NAME}-target.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
  VERSION ${VERSION}
  COMPATIBILITY AnyNewerVersion)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

# References: https://github.com/boost-cmake/bcm/wiki/Cmake-best-practices-and-guidelines
# https://github.com/jedisct1/libsodium/pull/74/files https://github.com/jedisct1/libsodium/pull/156/files
# https://github.com/jedisct1/libsodium/pull/181/files https://github.com/jedisct1/libsodium/issues/378
# https://github.com/jedisct1/libsodium/issues/636 https://github.com/jedisct1/libsodium/issues/771
# https://github.com/jedisct1/libsodium/blob/gyp/sodium.gyp https://github.com/imefisto/cmake-libsodium
# https://github.com/Cyberunner23/libsodium-CMake
# https://stackoverflow.com/questions/29901352/appending-to-cmake-c-flags
# https://stackoverflow.com/questions/986426/what-do-stdc-limit-macros-and-stdc-constant-macros-mean
# https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
# https://stackoverflow.com/questions/15132185/mixing-c-and-assembly-sources-and-build-with-cmake
# https://stackoverflow.com/questions/647892/how-to-check-header-files-and-library-functions-in-cmake-like-it-is-done-in-auto
# https://stackoverflow.com/questions/31038963/how-do-you-rename-a-library-filename-in-cmake
# https://gitlab.kitware.com/cmake/cmake/-/issues/15415
