#!/bin/sh
# Xcode Cloud runs this script after cloning the source tree, before any
# build step. We use it to override CURRENT_PROJECT_VERSION (the build
# number — i.e. CFBundleVersion) with the workflow's monotonic
# CI_BUILD_NUMBER so each TestFlight upload gets a unique number without
# us having to bump it manually in project.yml on every push.
#
# CI_BUILD_NUMBER is provided by Xcode Cloud and increases by one for
# every workflow run, across all builds in the workflow. Apple guarantees
# strict monotonicity even if some runs fail.

set -e

# Apple sets CI_PRIMARY_REPOSITORY_PATH to the absolute path of the
# checkout. Move there so sed targets the right pbxproj.
cd "$CI_PRIMARY_REPOSITORY_PATH"

if [ -z "${CI_BUILD_NUMBER:-}" ]; then
    echo "ci_post_clone: CI_BUILD_NUMBER not set — skipping (running outside Xcode Cloud?)"
    exit 0
fi

echo "ci_post_clone: setting CURRENT_PROJECT_VERSION = $CI_BUILD_NUMBER"

# Replace every CURRENT_PROJECT_VERSION = N; line in the pbxproj — the app
# target, the widget extension, and both test targets all use the same
# build number, which is what App Store Connect expects.
#
# The widget's static Info.plist already reads $(CURRENT_PROJECT_VERSION)
# and the main app uses GENERATE_INFOPLIST_FILE = YES, so updating the
# build setting alone propagates to every embedded CFBundleVersion.
sed -i.bak \
    "s/CURRENT_PROJECT_VERSION = [0-9][0-9]*;/CURRENT_PROJECT_VERSION = $CI_BUILD_NUMBER;/g" \
    Medity.xcodeproj/project.pbxproj
rm -f Medity.xcodeproj/project.pbxproj.bak

# Sanity-check that the substitution actually took.
COUNT=$(grep -c "CURRENT_PROJECT_VERSION = $CI_BUILD_NUMBER;" Medity.xcodeproj/project.pbxproj || true)
echo "ci_post_clone: $COUNT target(s) updated."
