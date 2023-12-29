#!/bin/bash


cd /srv/cyrus-imapd.git

set +e

autoreconf -i -s
./configure --enable-maintainer-mode
make distcheck

mkdir -p /usr/src
cd /usr/src
tar -zxf /srv/cyrus-imapd.git/cyrus-imapd-*.tar.gz
cd cyrus-imapd-*

# this is the basic build
LIBSDIR=/usr/local/cyruslibs
TARGET=/usr/cyrus
export PKG_CONFIG_PATH="$LIBSDIR/lib/x86_64-linux-gnu/pkgconfig:$LIBSDIR/lib/pkgconfig:\$PKG_CONFIG_PATH"
export CFLAGS="-g -fPIC -W -Wall -Wextra -Werror"
export CXXFLAGS="-g -fPIC -W -Wall -Wextra -Werror"
export PATH="$LIBSDIR/bin:$PATH"
./configure --enable-jmap --enable-http --enable-calalarmd --enable-unit-tests --enable-replication --enable-nntp --enable-murder --enable-idled --enable-xapian --enable-autocreate --enable-backup --enable-silent-rules
make lex-fix
make -j 8
make -j 8 check
sudo make install
sudo make install-binsymlinks
sudo cp tools/mkimap /usr/cyrus/bin/mkimap

# now that Cyrus is installed, let's test it with a full cassandane run!
sudo mkdir -p /tmp/cass
cd /src/cyrus-imapd.git/cassandane/
./testrunner.pl -f pretty -j 4 --config /src/cyrus-docker-release.git/cassandane.ini
