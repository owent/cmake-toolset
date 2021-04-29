#include <limits.h>

#include "gtest/gtest.h"

namespace {

TEST(LinkWithGTest, Zero) { EXPECT_EQ(1, 1); }

}  // namespace