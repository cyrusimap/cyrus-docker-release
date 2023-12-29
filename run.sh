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
CYRUSLIBS=/usr/local/cyruslibs
TARGET=/usr/cyrus
export LDFLAGS="-L$CYRUSLIBS/lib/x86_64-linux-gnu -L$CYRUSLIBS/lib -Wl,-rpath,$CYRUSLIBS/lib/x86_64-linux-gnu -Wl,-rpath,$CYRUSLIBS/lib"
export PKG_CONFIG_PATH="$CYRUSLIBS/lib/x86_64-linux-gnu/pkgconfig:$CYRUSLIBS/lib/pkgconfig:\$PKG_CONFIG_PATH"
export PATH=$CYRUSLIBS/bin:$PATH
export CFLAGS="-g -fPIC -W -Wall -Wextra -Werror"
export XAPIAN_CONFIG=$CYRUSLIBS/bin/xapian-config-1.5

./configure --prefix=$TARGET --enable-jmap --enable-http --enable-calalarmd --enable-unit-tests --enable-replication --enable-nntp --enable-murder --enable-idled --enable-xapian --enable-autocreate --enable-backup --enable-silent-rules --enable-autocreate
make -j 8
make sieve/test
make -j 8 check
make install
make install-binsymlinks
cp tools/mkimap /usr/cyrus/bin/mkimap
/bin/bash ./libtool --mode=install install -o root -m 755 sieve/test $TARGET/bin/sieve-test

# ipv6 is a crime
grep -v ::1 /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts

# now that Cyrus is installed, let's test it with a full cassandane run!
sudo install -o cyrus -g mail -d /tmp/cass
cd /srv/cyrus-imapd.git/cassandane/
make -j 8
export PERL5LIB=`echo /usr/cyrus/share/perl/*`
sudo -u cyrus ./testrunner.pl -f pretty -j 8 --config /srv/cyrus-docker-release.git/cassandane.ini
