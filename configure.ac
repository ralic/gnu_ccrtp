# Copyright (C) 1999-2003 Open Source Telecom Corporation.
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

AC_INIT(src/ccrtp/rtp.h)

cfg_options=""
if test -z "$*" ; then
        if test -f ~/.configure ; then
		cfg_options=`grep ^ccrtp: ~/.configure | sed -e s/^ccrtp://`
        elif test -f /etc/configure.conf ; then
		cfg_options=`grep ^ccrtp: /etc/configure.conf | sed -e s/^ccrtp://`   
        fi
fi

if test ! -z "$cfg_options" ; then
        echo "using ~/.configure defaults...$cfg_options"
        case "$SHELL" in       
        */bash*)
                exec $SHELL $0 $cfg_options
                exit -1
                ;;
        esac
        exec $0 $cfg_options
        exit -1
fi

VERSION="1.1.2"
REQUIRES="1.1.2"
LT_RELEASE="1.1"
LT_VERSION="0:1"
AC_CONFIG_AUX_DIR(autoconf)
AC_CANONICAL_SYSTEM
AC_PROG_CPP
AC_PROG_CXXCPP
AC_PROG_CXX
# OST_PROG_CC_POSIX
AM_PROG_LIBTOOL
AM_INIT_AUTOMAKE(ccrtp,[$VERSION])
AM_CONFIG_HEADER(src/config.h)

OST_DEBUG

OST_PROG_COMMON
OST_PROG_LIBVER
OST_PROG_LIBRARY(CCXX,[$LT_VERSION])
OST_AUTOMAKE_MODE
OST_MAINTAINER_MODE
OST_CCXX2_VERSION([$REQUIRES])
# OST_CC_ENDIAN - now in Common C++
# Are we using the GNU compiler?
if test $GCC = yes ; then
	WARN_FLAGS="-Wall -ansi -pedantic"
else
	WARN_FLAGS=""
fi
AC_SUBST(WARN_FLAGS)
dnl --with-nana: check for nana, the GNU assertion checking and logging library
AC_ARG_WITH(nana,[  --with-nana             use GNU nana for asserts and logging],[
	AC_CHECK_HEADER(nana.h, [
		AC_CHECK_HEADERS(DL.h, [
			AC_CHECK_LIB(nana, main)
			])
	])
])
KDOC_DIR="\$(top_srcdir)/doc"
AC_SUBST(LT_RELEASE)
AC_SUBST(KDOC_DIR)

AC_ARG_WITH(commoncpp,
	[  --with-commoncpp=<sources> where commonc++ sources are],
	[COMMONCPP=`echo $with_commoncpp`
	rm -f doc/doxy
	if test -d "$COMMONCPP" ; then
		if test ! -d w32/include; then mkdir w32/include ; fi
		if test ! -d w32/template ; then mkdir w32/template ; fi
		rm -f w32/src
		ln -s "$COMMONCPP/src" w32/src
		rm -f w32/include/cc++
		ln -s "$COMMONCPP/include/cc++" w32/include/cc++
		rm -f w32/template/cc++
		ln -s "$COMMONCPP/template" w32/template/cc++
		rm -f w32/common/cc++
		ln -s "$COMMONCPP/w32/cc++" w32/common/cc++
	else
		rm -rf include
		rm -rf template
		rm -f w32/src
		rm -f w32/common/cc++
	fi])	

AC_PATH_PROG(DOXYGEN, doxygen, no)
AC_SUBST(DOXYGEN)
AM_CONDITIONAL(DOXY, test "$DOXYGEN" != "no")
AM_CONDITIONAL(COMMON, test -d w32/include)

AC_OUTPUT(Makefile src/Makefile src/ccrtp/Makefile m4/Makefile 
doc/Makefile demo/Makefile phone/Makefile w32/Makefile ccrtp.spec
ccrtp.list)