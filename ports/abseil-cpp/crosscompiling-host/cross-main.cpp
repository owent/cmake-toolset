// Copyright 2023 atframework

#include <iostream>
#include <memory>
#include <string>

#include "absl/base/config.h"

int main(int argc, char** argv) {
  std::cout << "ABSL_LTS_RELEASE_VERSION=" << ABSL_LTS_RELEASE_VERSION << std::endl;
  return 0;
}
