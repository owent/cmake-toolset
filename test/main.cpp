#include <iostream>

#if defined(HAVE_PROTOBUF) && HAVE_PROTOBUF

#  if defined(_MSC_VER)
#    pragma warning(push)
#    if ((defined(__cplusplus) && __cplusplus >= 201704L) || (defined(_MSVC_LANG) && _MSVC_LANG >= 201704L))
#      pragma warning(disable : 4996)
#      pragma warning(disable : 4309)
#      if _MSC_VER >= 1922
#        pragma warning(disable : 5054)
#      endif
#    endif

#    if _MSC_VER < 1910
#      pragma warning(disable : 4800)
#    endif
#    pragma warning(disable : 4244)
#    pragma warning(disable : 4251)
#    pragma warning(disable : 4267)
#  endif

#  if defined(__GNUC__) && !defined(__clang__) && !defined(__apple_build_version__)
#    if (__GNUC__ * 100 + __GNUC_MINOR__ * 10) >= 460
#      pragma GCC diagnostic push
#    endif
#    pragma GCC diagnostic ignored "-Wunused-parameter"
#    pragma GCC diagnostic ignored "-Wtype-limits"
#  elif defined(__clang__) || defined(__apple_build_version__)
#    pragma clang diagnostic push
#    pragma clang diagnostic ignored "-Wunused-parameter"
#    pragma clang diagnostic ignored "-Wtype-limits"
#  endif

#  include "test_pb.pb.h"

#  if defined(__GNUC__) && !defined(__clang__) && !defined(__apple_build_version__)
#    if (__GNUC__ * 100 + __GNUC_MINOR__ * 10) >= 460
#      pragma GCC diagnostic pop
#    endif
#  elif defined(__clang__) || defined(__apple_build_version__)
#    pragma clang diagnostic pop
#  endif

#  if defined(_MSC_VER)
#    pragma warning(pop)
#  endif

#endif

int main() {
#if defined(HAVE_PROTOBUF) && HAVE_PROTOBUF
  cmake_toolset::test_message msg;
  msg.set_i32(123);
  msg.set_i64(123000);
  msg.set_str("Hello World!");

  std::cout << msg.DebugString() << std::endl;
#else
  std::cout << "Hello World!" << std::endl;
#endif
  return 0;
}
