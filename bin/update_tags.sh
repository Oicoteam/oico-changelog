#!/bin/sh

# Script to simplify the release flow.
# 1) Fetch the current release version
# 2) Increase the version (major, minor, patch)
# 3) Add a new git tag
# 4) Push the tag

# Parse command line options.
while getopts ":Mmpd" Option
do
  case $Option in
    M ) major=true;;
    m ) minor=true;;
    p ) patch=true;;
  esac
done

shift $(($OPTIND - 1))

# Display usage
if [ -z $major ] && [ -z $minor ] && [ -z $patch ];
then
  echo "usage: $(basename $0) [Mmp] [message]"
  echo ""
  echo "  -M for a major release"
  echo "  -m for a minor release"
  echo "  -p for a patch release"
  echo ""
  echo " Example: release -p \"Some fix\""
  echo " means create a patch release with the message \"Some fix\""
  exit 1
fi

# Force to the root of the project
pushd "$(dirname $0)/../"

# 1) Fetch the current release version
echo "Fetch tags"
git fetch --all --tags

version=$(git describe --tags --abbrev=0)
version=${version:1} # Remove the v in the tag v0.37.10 for example

echo "Current version: $version"

# 2) Increase version number
# Build array from version string.

a=( ${version//./ } )

# Increment version numbers as requested.

if [ ! -z $major ]
then
  ((a[0]++))
  a[1]=0
  a[2]=0
fi

if [ ! -z $minor ]
then
  ((a[1]++))
  a[2]=0
fi

if [ ! -z $patch ]
then
  ((a[2]++))
fi

if [[ $version == '' ]]
then
  next_version="1.0.0"
else
  next_version="${a[0]}.${a[1]}.${a[2]}"
fi

# If a command fails, exit the script
set -e

# 3) Add git tag
echo "Add git tag v$next_version with message: $msg"
git tag "v$next_version"

# 4) Push the new tag
echo "Push the tag"
git push --tags

echo -e "Release done: $next_version"

popd
