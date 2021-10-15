// Copyright 2021 atframework

#include <iostream>
#include <string>

#if defined(HAVE_OPENTELEMETRY_CPP) && HAVE_OPENTELEMETRY_CPP
#  include "opentelemetry/exporters/ostream/span_exporter.h"
#  include "opentelemetry/sdk/trace/batch_span_processor.h"
#  include "opentelemetry/sdk/trace/tracer_provider.h"
#  include "opentelemetry/trace/provider.h"
#endif

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

#if defined(HAVE_OPENTELEMETRY_CPP) && HAVE_OPENTELEMETRY_CPP

constexpr int kOpentelemetryNumSpans = 3;

namespace {

static void OpentelemetryInitTracer() {
  auto exporter =
      std::unique_ptr<opentelemetry::sdk::trace::SpanExporter>(new opentelemetry::exporter::trace::OStreamSpanExporter);

  // CONFIGURE BATCH SPAN PROCESSOR PARAMETERS

  opentelemetry::sdk::trace::BatchSpanProcessorOptions options{};
  // We make the queue size `kOpentelemetryNumSpans`*2+5 because when the queue is half full, a preemptive notif
  // is sent to start an export call, which we want to avoid in this simple example.
  options.max_queue_size = kOpentelemetryNumSpans * 2 + 1;
  // Time interval (in ms) between two consecutive exports.
  options.schedule_delay_millis = std::chrono::milliseconds(3000);
  // We export `kOpentelemetryNumSpans` after every `schedule_delay_millis` milliseconds.
  options.max_export_batch_size = kOpentelemetryNumSpans;

  auto processor = std::unique_ptr<opentelemetry::sdk::trace::SpanProcessor>(
      new opentelemetry::sdk::trace::BatchSpanProcessor(std::move(exporter), options));

  auto provider = nostd::shared_ptr<opentelemetry::trace::TracerProvider>(
      new opentelemetry::sdk::trace::TracerProvider(std::move(processor)));
  // Set the global trace provider.
  opentelemetry::trace::Provider::SetTracerProvider(provider);
}

nostd::shared_ptr<opentelemetry::trace::Tracer> GetTracer() {
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
  OpentelemetryStartAndEndSpans();
}

}  // namespace
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
#if defined(HAVE_OPENTELEMETRY_CPP) && HAVE_OPENTELEMETRY_CPP
  OpentelemetryTest();
#endif
  return 0;
}
