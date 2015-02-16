#!/bin/bash

set -e

TARGET=$1

echo Building Sensu gems for: $TARGET

if [ "$2" = "--" ]; then
	shift 2
	DEPENDENCIES=$@
fi

EMBEDDED_PATH=/opt/sensu/embedded/bin
GEM=$EMBEDDED_PATH/gem
FPM=$EMBEDDED_PATH/fpm

PREFIX=sensu-gem
OPTIONS="--gem-gem $GEM --gem-package-name-prefix=$PREFIX"

EXCLUDED_DEPENDENCIES=$(/opt/sensu/embedded/bin/gem list --no-versions)

for dependency in $EXCLUDED_DEPENDENCIES; do
	OPTIONS="$OPTIONS --gem-disable-dependency $dependency"
done

if [ $DEPENDENCIES ]; then
	apt-get install -y --force-yes $DEPENDENCIES
fi

$GEM install --no-ri --no-rdoc --install-dir /tmp/gems $TARGET

set +e

find /tmp/gems -name *.gem -exec $FPM -p /out -d sensu -s gem -t deb $OPTIONS {}  \;