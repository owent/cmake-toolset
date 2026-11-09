// Copyright 2021 atframework

#include <atomic>
#include <iostream>
#include <string>

#if defined(HAVE_OPENTELEMETRY_CPP) && HAVE_OPENTELEMETRY_CPP
#  include "opentelemetry/exporters/ostream/span_exporter_factory.h"
#  include "opentelemetry/sdk/trace/batch_span_processor.h"
#  include "opentelemetry/sdk/trace/batch_span_processor_factory.h"
#  include "opentelemetry/sdk/trace/batch_span_processor_options.h"
#  include "opentelemetry/sdk/trace/exporter.h"
#  include "opentelemetry/sdk/trace/tracer_provider_factory.h"
#  include "opentelemetry/trace/provider.h"

#endif

#if defined(HAVE_PROTOBUF) && HAVE_PROTOBUF

// There ares some warnings in prorobuf generated codes, we just disable these warnings
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

// Simple API calls for every linked non-header-only third-party library, to make sure they all
// compile, link, and run.
#if defined(HAVE_ZLIB) && HAVE_ZLIB
#  include <zlib.h>
#endif
#if defined(HAVE_LZ4) && HAVE_LZ4
#  include <lz4.h>
#endif
#if defined(HAVE_SNAPPY) && HAVE_SNAPPY
#  include <snappy.h>
#endif
#if defined(HAVE_ZSTD) && HAVE_ZSTD
#  include <zstd.h>
#endif
#if defined(HAVE_JEMALLOC) && HAVE_JEMALLOC
#  include <jemalloc/jemalloc.h>
#endif
#if defined(HAVE_LIBUNWIND) && HAVE_LIBUNWIND
#  define UNW_LOCAL_ONLY
#  include <libunwind.h>
#endif
#if defined(HAVE_MIMALLOC) && HAVE_MIMALLOC
#  include <mimalloc.h>
#endif
#if defined(HAVE_XXHASH) && HAVE_XXHASH
#  include <xxhash.h>
#endif
#if defined(HAVE_TBB) && HAVE_TBB
#  include <tbb/parallel_for.h>
#endif
#if defined(HAVE_LIBUV) && HAVE_LIBUV
#  include <uv.h>
#endif
#if defined(HAVE_LUA) && HAVE_LUA
extern "C" {
#  include <lauxlib.h>
#  include <lua.h>
#  include <lualib.h>
}
#endif
#if defined(HAVE_FMTLIB) && HAVE_FMTLIB
#  include <fmt/format.h>
#endif
#if defined(HAVE_YAML_CPP) && HAVE_YAML_CPP
#  include <yaml-cpp/yaml.h>
#endif
#if defined(HAVE_NLOHMANN_JSON) && HAVE_NLOHMANN_JSON
#  include <nlohmann/json.hpp>
#endif
#if defined(HAVE_RAPIDJSON) && HAVE_RAPIDJSON
#  include <rapidjson/document.h>
#endif
#if defined(HAVE_FLATBUFFERS) && HAVE_FLATBUFFERS
#  include "helloworld_generated.h"
#endif
#if defined(HAVE_SSL) && HAVE_SSL
#  include <openssl/ssl.h>
#endif
#if defined(HAVE_SSL_MBEDTLS) && HAVE_SSL_MBEDTLS
#  include <mbedtls/version.h>
#endif
#if defined(HAVE_LIBEVENT) && HAVE_LIBEVENT
#  include <event2/event.h>
#endif
#if defined(HAVE_HIREDIS) && HAVE_HIREDIS
#  include <hiredis/hiredis.h>
#endif
#if defined(HAVE_CARES) && HAVE_CARES
#  include <ares.h>
#endif
#if defined(HAVE_RE2) && HAVE_RE2
#  include <re2/re2.h>
#endif
#if defined(HAVE_NGHTTP3) && HAVE_NGHTTP3
#  include <nghttp3/nghttp3.h>
#endif
#if defined(HAVE_NGTCP2) && HAVE_NGTCP2
#  include <ngtcp2/ngtcp2.h>
#endif
#if defined(HAVE_NGHTTP2) && HAVE_NGHTTP2
#  include <nghttp2/nghttp2.h>
#endif
#if defined(HAVE_LIBCURL) && HAVE_LIBCURL
#  include <curl/curl.h>
#endif
#if defined(HAVE_CIVETWEB) && HAVE_CIVETWEB
#  include <civetweb.h>
#endif
#if defined(HAVE_LIBWEBSOCKETS) && HAVE_LIBWEBSOCKETS
#  include <libwebsockets.h>
#endif
#if defined(HAVE_GRPC) && HAVE_GRPC
#  include <grpc/grpc.h>
#endif
#if defined(HAVE_PROMETHEUS_CPP) && HAVE_PROMETHEUS_CPP
#  include <prometheus/counter.h>
#  include <prometheus/registry.h>
#endif
#if defined(HAVE_LIBCOPP) && HAVE_LIBCOPP
#  include <libcotask/task.h>
#endif

#if defined(HAVE_OPENTELEMETRY_CPP) && HAVE_OPENTELEMETRY_CPP

constexpr int kOpentelemetryNumSpans = 3;

namespace {

static void OpentelemetryInitTracer() {
  auto exporter = opentelemetry::exporter::trace::OStreamSpanExporterFactory::Create();

  // CONFIGURE BATCH SPAN PROCESSOR PARAMETERS

  opentelemetry::sdk::trace::BatchSpanProcessorOptions options;
  // We make the queue size `kOpentelemetryNumSpans`*2+5 because when the queue is half full, a preemptive notif
  // is sent to start an export call, which we want to avoid in this simple example.
  options.max_queue_size = kOpentelemetryNumSpans * 2 + 1;
  // Time interval (in ms) between two consecutive exports.
  options.schedule_delay_millis = std::chrono::milliseconds(3000);
  // We export `kOpentelemetryNumSpans` after every `schedule_delay_millis` milliseconds.
  options.max_export_batch_size = kOpentelemetryNumSpans;

  auto processor = opentelemetry::sdk::trace::BatchSpanProcessorFactory::Create(std::move(exporter), options);

  auto provider = opentelemetry::sdk::trace::TracerProviderFactory::Create(std::move(processor));
  // Set the global trace provider.
  opentelemetry::trace::Provider::SetTracerProvider(
      opentelemetry::nostd::shared_ptr<opentelemetry::trace::TracerProvider>{provider.release()});
}

opentelemetry::nostd::shared_ptr<opentelemetry::trace::Tracer> GetTracer() {
  auto provider = opentelemetry::trace::Provider::GetTracerProvider();
  return provider->GetTracer("cmake-toolset-test");
}

static void OpentelemetryStartAndEndSpans() {
  for (int i = 1; i <= kOpentelemetryNumSpans; ++i) {
    std::string msg = "cmake-toolset-test-batch: ";
    msg += static_cast<char>(i + '0');
    GetTracer()->StartSpan(msg);
  }
}

static void OpentelemetryTest() {
  OpentelemetryInitTracer();
  OpentelemetryStartAndEndSpans();
  OpentelemetryStartAndEndSpans();

  // Create enough spans to let BatchSpanProcessor to submit spans
  OpentelemetryStartAndEndSpans();
  // We should see the spans exported by OStreamSpanExporter here
}

}  // namespace
#endif

int main() {
#if defined(HAVE_PROTOBUF) && HAVE_PROTOBUF
  // Test protobuf
  cmake_toolset::test_message msg;
  msg.set_i32(123);
  msg.set_i64(123000);
  msg.set_str("Hello World!");

  std::cout << msg.DebugString() << std::endl;
#else
  std::cout << "Hello World!" << std::endl;
#endif
#if defined(HAVE_OPENTELEMETRY_CPP) && HAVE_OPENTELEMETRY_CPP
  // Test opentelemetry
  OpentelemetryTest();
#endif

#if defined(HAVE_ZLIB) && HAVE_ZLIB
  std::cout << "zlib: " << zlibVersion() << std::endl;
#endif
#if defined(HAVE_LZ4) && HAVE_LZ4
  std::cout << "lz4: " << LZ4_versionNumber() << std::endl;
#endif
#if defined(HAVE_SNAPPY) && HAVE_SNAPPY
  {
    std::string snappy_compressed;
    snappy::Compress("hello world", 11, &snappy_compressed);
    std::cout << "snappy: " << snappy_compressed.size() << std::endl;
  }
#endif
#if defined(HAVE_ZSTD) && HAVE_ZSTD
  std::cout << "zstd: " << ZSTD_versionNumber() << std::endl;
#endif
#if defined(HAVE_JEMALLOC) && HAVE_JEMALLOC
  {
    const char* jemalloc_version = nullptr;
    size_t jemalloc_version_size = sizeof(jemalloc_version);
    mallctl("version", &jemalloc_version, &jemalloc_version_size, nullptr, 0);
    std::cout << "jemalloc: " << (nullptr != jemalloc_version ? jemalloc_version : "unknown") << std::endl;
  }
#endif
#if defined(HAVE_LIBUNWIND) && HAVE_LIBUNWIND
  {
    unw_context_t libunwind_context;
    if (0 == unw_getcontext(&libunwind_context)) {
      std::cout << "libunwind: getcontext ok" << std::endl;
    }
  }
#endif
#if defined(HAVE_MIMALLOC) && HAVE_MIMALLOC
  std::cout << "mimalloc: " << mi_version() << std::endl;
#endif
#if defined(HAVE_XXHASH) && HAVE_XXHASH
  std::cout << "xxhash: " << XXH_versionNumber() << std::endl;
#endif
#if defined(HAVE_TBB) && HAVE_TBB
  {
    std::atomic<int> tbb_sum{0};
    tbb::parallel_for(0, 10, [&tbb_sum](int value) { tbb_sum += value; });
    std::cout << "tbb: " << tbb_sum.load() << std::endl;
  }
#endif
#if defined(HAVE_LIBUV) && HAVE_LIBUV
  std::cout << "libuv: " << uv_version() << std::endl;
#endif
#if defined(HAVE_LUA) && HAVE_LUA
  {
    lua_State* lua_state = luaL_newstate();
    if (nullptr != lua_state) {
      luaL_openlibs(lua_state);
      lua_close(lua_state);
    }
    std::cout << "lua: " << LUA_VERSION << std::endl;
  }
#endif
#if defined(HAVE_FMTLIB) && HAVE_FMTLIB
  std::cout << "fmt: " << fmt::format("{}", 42) << std::endl;
#endif
#if defined(HAVE_YAML_CPP) && HAVE_YAML_CPP
  {
    YAML::Node yaml_node;
    yaml_node["hello"] = "world";
    std::cout << "yaml-cpp: " << yaml_node["hello"].as<std::string>() << std::endl;
  }
#endif
#if defined(HAVE_NLOHMANN_JSON) && HAVE_NLOHMANN_JSON
  {
    auto nlohmann_json_value = nlohmann::json::parse(R"({"hello":"world"})");
    std::cout << "nlohmann_json: " << nlohmann_json_value["hello"].get<std::string>() << std::endl;
  }
#endif
#if defined(HAVE_RAPIDJSON) && HAVE_RAPIDJSON
  {
    rapidjson::Document rapidjson_document;
    rapidjson_document.Parse(R"({"hello":"world"})");
    std::cout << "rapidjson: " << rapidjson_document["hello"].GetString() << std::endl;
  }
#endif
#if defined(HAVE_FLATBUFFERS) && HAVE_FLATBUFFERS
  {
    flatbuffers::FlatBufferBuilder flatbuffers_builder;
    auto flatbuffers_name = flatbuffers_builder.CreateString("cmake-toolset");
    auto flatbuffers_request = helloworld::CreateHelloRequest(flatbuffers_builder, flatbuffers_name);
    flatbuffers_builder.Finish(flatbuffers_request);
    auto* flatbuffers_root =
        flatbuffers::GetRoot<helloworld::HelloRequest>(flatbuffers_builder.GetBufferPointer());
    std::cout << "flatbuffers: " << flatbuffers_root->name()->str() << std::endl;
  }
#endif
#if defined(HAVE_SSL) && HAVE_SSL
  std::cout << "ssl: " << OpenSSL_version(OPENSSL_VERSION) << std::endl;
#endif
#if defined(HAVE_SSL_MBEDTLS) && HAVE_SSL_MBEDTLS
  {
    char mbedtls_version_string[64] = {0};
    mbedtls_version_get_string_full(mbedtls_version_string);
    std::cout << "mbedtls: " << mbedtls_version_string << std::endl;
  }
#endif
#if defined(HAVE_LIBEVENT) && HAVE_LIBEVENT
  {
    auto* libevent_base = event_base_new();
    if (nullptr != libevent_base) {
      std::cout << "libevent: " << event_base_get_method(libevent_base) << std::endl;
      event_base_free(libevent_base);
    }
  }
#endif
#if defined(HAVE_HIREDIS) && HAVE_HIREDIS
  redisFree(nullptr);  // NULL is safe in hiredis, this only checks the library links
  std::cout << "hiredis: " << HIREDIS_MAJOR << "." << HIREDIS_MINOR << "." << HIREDIS_PATCH << std::endl;
#endif
#if defined(HAVE_CARES) && HAVE_CARES
  std::cout << "c-ares: " << ares_version(nullptr) << std::endl;
#endif
#if defined(HAVE_RE2) && HAVE_RE2
  {
    int re2_value = 0;
    RE2 re2_pattern(R"((\d+))");
    RE2::FullMatch("123", re2_pattern, &re2_value);
    std::cout << "re2: " << re2_value << std::endl;
  }
#endif
#if defined(HAVE_NGHTTP3) && HAVE_NGHTTP3
  std::cout << "nghttp3: " << nghttp3_version(0)->version_str << std::endl;
#endif
#if defined(HAVE_NGTCP2) && HAVE_NGTCP2
  std::cout << "ngtcp2: " << ngtcp2_version(0)->version_str << std::endl;
#endif
#if defined(HAVE_NGHTTP2) && HAVE_NGHTTP2
  std::cout << "nghttp2: " << nghttp2_version(0)->version_str << std::endl;
#endif
#if defined(HAVE_LIBCURL) && HAVE_LIBCURL
  std::cout << "libcurl: " << curl_version() << std::endl;
#endif
#if defined(HAVE_CIVETWEB) && HAVE_CIVETWEB
  std::cout << "civetweb: " << mg_version() << std::endl;
#endif
#if defined(HAVE_LIBWEBSOCKETS) && HAVE_LIBWEBSOCKETS
  std::cout << "libwebsockets: " << lws_get_library_version() << std::endl;
#endif
#if defined(HAVE_GRPC) && HAVE_GRPC
  std::cout << "grpc: " << grpc_version_string() << std::endl;
#endif
#if defined(HAVE_PROMETHEUS_CPP) && HAVE_PROMETHEUS_CPP
  {
    prometheus::Registry prometheus_registry;
    auto& prometheus_counter_family =
        prometheus::BuildCounter().Name("cmake_toolset_test_counter").Register(prometheus_registry);
    auto& prometheus_counter = prometheus_counter_family.Add({{"test", "main"}});
    prometheus_counter.Increment();
    std::cout << "prometheus-cpp: " << prometheus_counter.Value() << std::endl;
  }
#endif
#if defined(HAVE_LIBCOPP) && HAVE_LIBCOPP
  {
    auto libcopp_task = cotask::task<>::create([]() { return 42; });
    if (libcopp_task && 0 == libcopp_task->start()) {
      std::cout << "libcopp: task started" << std::endl;
    }
  }
#endif
  return 0;
}
