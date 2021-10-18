// Copyright 2021 atframework

#include <limits.h>

#include "gtest/gtest.h"

namespace {

TEST(LinkWithGTest, Zero) {
  // Test for gtest_main
  EXPECT_EQ(1, 1);
}

}  // namespace