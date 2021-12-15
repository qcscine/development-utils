#
# This file is licensed under the 3-clause BSD license.
# Copyright ETH Zurich, Laboratory for Physical Chemistry, Reiher Group.
# See LICENSE.txt for details.
#

# Unfortunately, conan generates a GTest::GTest target that links against all
# of the components, two of which contain a main function. But it checks
# whether the target already exists, so we make use of that here by defining
# the target before the find module can.
add_library(GTest::GTest INTERFACE IMPORTED)
find_package(GTest)

# We have some weird logic in our ImportGTest that defines a specific set of
# targets for us, and these need to be present.
target_link_libraries(GTest::GTest INTERFACE GTest::gtest)

add_library(GTest::Main INTERFACE IMPORTED)
target_link_libraries(GTest::Main INTERFACE GTest::gtest_main)

add_library(GMock::GMock INTERFACE IMPORTED)
target_link_libraries(GMock::GMock INTERFACE GTest::gmock)

add_library(GMock::Main INTERFACE IMPORTED)
target_link_libraries(GMock::Main INTERFACE GTest::gmock_main)
