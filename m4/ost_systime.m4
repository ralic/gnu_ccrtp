dnl Copyright (C) 1999-2001 Open Source Telecom Corporation.
dnl  
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl 
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl 
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software 
dnl Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
dnl 
dnl As a special exception to the GNU General Public License, if you 
dnl distribute this file as part of a program that contains a configuration 
dnl script generated by Autoconf, you may include it under the same 
dnl distribution terms that you use for the rest of that program.

AC_DEFUN(OST_HEADER_SYSTIME,[
	AC_HEADER_TIME
	AC_CHECK_HEADERS(sys/time.h)
])

dnl ACCONFIG TEMPLATE
dnl #undef HAVE_SYS_TIME_H
dnl #undef TIME_WITH_SYS_TIME
dnl END ACCONFIG

dnl ACCONFIG BOTTOM
dnl  
dnl #if TIME_WITH_SYS_TIME
dnl #include <sys/time.h>
dnl #include <time.h>
dnl #else
dnl #if HAVE_SYS_TIME_H
dnl #include <sys/time.h>
dnl #else
dnl #include <time.h>
dnl #endif
dnl #endif
dnl 
dnl END ACCONFIG

