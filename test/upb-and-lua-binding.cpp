// Copyright 2022 atframework

#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

// #include "upb/def.hpp"
// #include "upb/json_decode.h"
// #include "upb/json_encode.h"
#include "upb/upb.hpp"

#include "test_pb.upb.h"
#include "test_pb.upbdefs.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"

#if defined (UPB_BINDING_LUA_WITH_LEGACY_BINDING)
#  include "upb/lua/upb.h"
#else
#  include "lua/upb.h"
#endif
#ifdef __cplusplus
}
#endif

int main(int argc, char* argv[]) {
  std::string init_script = "package.preload['lupb'] = ... ";
  std::vector<std::string> load_files;
  for (int i = 1; i < argc; ++i) {
    size_t len = strlen(argv[i]);
    if (len >= 4 && std::string(&argv[i][len - 4]) == ".lua") {
      load_files.push_back(argv[i]);
    } else {
      init_script += "package.path = '" + std::string(argv[i]) + "/?.lua;' .. package.path\n";
    }
  }

  // Lua binding
  {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    // luaopen_lupb(L);
    std::cout << "Load lupb ..." << std::endl;
    lua_pushcfunction(L, luaopen_lupb);
    luaL_loadstring(L, init_script.c_str());
    lua_pushcfunction(L, luaopen_lupb);
    if (lua_pcall(L, 1, LUA_MULTRET, 0)) {
      std::cout << "Load lupb failed" << std::endl;
    }

    if (load_files.empty()) {
      upb::Arena arena;
      cmake_toolset_test_message* test_msg = cmake_toolset_test_message_new(arena.ptr());
      // cmake_toolset_test_message_set_str(test_msg, upb_StringView_FromString("hello world!")); // New implementation
      // cmake_toolset_test_message_set_str(test_msg, upb_strview_makez("hello world!")); // Old implementation
      cmake_toolset_test_message_set_i64(test_msg, 123321);
      size_t size;
      cmake_toolset_test_message_serialize(test_msg, arena.ptr(), &size);
      std::cout << "Serialized test message size: " << size << std::endl;

      std::cout << "Run lua code:" << std::endl;
      std::string script =
          "local _, err = pcall(function() print(string.format('Message Count: %g', "
          "require('test_pb_pb')._filedef:msgcount())) end)\n";
      script += "if err ~= nil then print(err) end\n";
      luaL_dostring(L, script.c_str());
      script = "local _, err = pcall(function() print('File Name: ' .. require('test_pb_pb')._filedef:name()) end)\n";
      script += "if err ~= nil then print(err) end\n";
      luaL_dostring(L, script.c_str());

      std::cout << "End" << std::endl;
    } else {
      int top = lua_gettop(L);
      for (auto& script_file : load_files) {
        std::cout << "Run lua file:" << script_file << std::endl;
        if (LUA_OK != luaL_dofile(L, script_file.c_str())) {
          int new_top = lua_gettop(L);
          if (new_top > top) {
            if (lua_isstring(L, top + 1) || lua_isnumber(L, top + 1)) {
              std::cerr << lua_tostring(L, top + 1) << std::endl;
            } else {
              lua_getglobal(L, "tostring");
              lua_pushvalue(L, top + 1);
              lua_call(L, 1, 1);
              std::cerr << lua_tostring(L, -1) << std::endl;
            }
          }
        }
        lua_settop(L, top);
      }
    }

    lua_close(L);
  }
  return 0;
}
