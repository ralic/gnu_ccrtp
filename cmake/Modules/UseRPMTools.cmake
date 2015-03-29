# Copyright (C) 2010-2015 Werner Dittmann <werner.dittmann@t-online.de>
#
# Redistribution and use, with or without modification, are permitted
# provided that the following conditions are met:
# 
#    1. Redistributions must retain the above copyright notice, this
#       list of conditions and the following disclaimer.
#    2. The name of the author may not be used to endorse or promote
#       products derived from this software without specific prior
#       written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# - Find tools needed for building RPM Packages
#   on Linux systems and defines macro that helps to
#   build source or binary RPM, the MACRO assumes
#   CMake 2.4.x which includes CPack support.
#   CPack is used to build tar.gz source tarball
#   which may be used by a custom user-made spec file.
#
# - Define RPMTools_ADD_RPM_TARGETS which defines
#   two (top-level) CUSTOM targets for building
#   source and binary RPMs
#
# Those CMake macros are provided by the TSP Developer Team
# https://savannah.nongnu.org/projects/tsp
#
# Modified by Werner to use the SoureDistribution variables and
# files instead of CPack stuff. Only minor changes.

IF (WIN32)  
  MESSAGE(STATUS "RPM tools not available on Win32 systems")
ENDIF(WIN32)

IF (UNIX)
  # Look for RPM builder executable
  FIND_PROGRAM(RPMTools_RPMBUILD_EXECUTABLE 
    NAMES rpmbuild
    PATHS "/usr/bin;/usr/lib/rpm"
    PATH_SUFFIXES bin
    DOC "The RPM builder tool")
  
  IF (RPMTools_RPMBUILD_EXECUTABLE)
    MESSAGE(STATUS "Looking for RPMTools... - found rpmuild is ${RPMTools_RPMBUILD_EXECUTABLE}")
    SET(RPMTools_RPMBUILD_FOUND "YES")
    GET_FILENAME_COMPONENT(RPMTools_BINARY_DIRS ${RPMTools_RPMBUILD_EXECUTABLE} PATH)
  ELSE (RPMTools_RPMBUILD_EXECUTABLE) 
    SET(RPMTools_RPMBUILD_FOUND "NO")
    MESSAGE(STATUS "Looking for RPMTools... - rpmbuild NOT FOUND")
  ENDIF (RPMTools_RPMBUILD_EXECUTABLE) 
  
  # Detect if CourceDistribution was initialized or not
  IF (NOT DEFINED "SRC_DIST_DIR") 
    MESSAGE(FATAL_ERROR "SourceDistribution was not initialized")
  ENDIF (NOT DEFINED "SRC_DIST_DIR")
  
  IF (RPMTools_RPMBUILD_FOUND)
    SET(RPMTools_FOUND TRUE)    
    #
    # - first arg  (ARGV0) is RPM name
    # - second arg (ARGV1) is the RPM spec file path [optional]
    # - third arg  (ARGV2) is the RPM ROOT DIRECTORY used to build RPMs [optional]
    #
    MACRO(RPMTools_ADD_RPM_TARGETS RPMNAME)

      #
      # If no spec file is provided create a minimal one
      #
      IF ("${ARGV1}" STREQUAL "")
        SET(SPECFILE_PATH "${CMAKE_BINARY_DIR}/${RPMNAME}.spec")
      ELSE ("${ARGV1}" STREQUAL "")
        SET(SPECFILE_PATH "${ARGV1}")
      ENDIF("${ARGV1}" STREQUAL "")
      
      # Verify whether if RPM_ROOTDIR was provided or not
      IF("${ARGV2}" STREQUAL "") 
        SET(RPM_ROOTDIR ${CMAKE_BINARY_DIR}/RPM)
      ELSE ("${ARGV2}" STREQUAL "")
        SET(RPM_ROOTDIR "${ARGV2}") 
      ENDIF("${ARGV2}" STREQUAL "")
      MESSAGE(STATUS "RPMTools:: Using RPM_ROOTDIR=${RPM_ROOTDIR}")

      # Prepare RPM build tree
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR})
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR}/tmp)
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR}/BUILD)
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR}/RPMS)
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR}/SOURCES)
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR}/SPECS)
      FILE(MAKE_DIRECTORY ${RPM_ROOTDIR}/SRPMS)

      #
      # We check whether if the provided spec file is
      # to be configure or not.
      # 
      IF ("${ARGV1}" STREQUAL "")
        SET(SPECFILE_PATH "${RPM_ROOTDIR}/SPECS/${RPMNAME}.spec")
        SET(SPECFILE_NAME "${RPMNAME}.spec")
        MESSAGE(STATUS "No Spec file given generate a minimal one --> ${RPM_ROOTDIR}/SPECS/${RPMNAME}.spec")
        FILE(WRITE ${RPM_ROOTDIR}/SPECS/${RPMNAME}.spec
      "# -*- rpm-spec -*-
Summary:        ${RPMNAME}
Name:           ${RPMNAME}
Version:        ${PACKAGE_VERSION}
Release:        1
License:        Unknown
Group:          Unknown
Source:         ${SRC_DIST_DIR}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires:  cmake

%define prefix /opt/${RPMNAME}-%{version}
%define rpmprefix $RPM_BUILD_ROOT%{prefix}
%define srcdirname %{name}-%{version}-Source

%description
${RPMNAME} : No description for now

%prep
%setup -q -n %{srcdirname}

%build
cd ..
rm -rf build_tree
mkdir build_tree
cd build_tree
cmake -DCMAKE_INSTALL_PREFIX=%{rpmprefix} ../%{srcdirname}
make
  
%install 
cd ../build_tree
make install

%clean
rm -rf %{srcdirname}
rm -rf build_tree

%files
%defattr(-,root,root,-)
%dir %{prefix}
%{prefix}/*

%changelog
* Wed Feb 28 2007 Erk <eric.noulard@gmail.com>
  Generated by CMake UseRPMTools macros"
        )

      ELSE ("${ARGV1}" STREQUAL "")
        SET(SPECFILE_PATH "${ARGV1}")
    
        GET_FILENAME_COMPONENT(SPECFILE_EXT ${SPECFILE_PATH} EXT)      
        IF ("${SPECFILE_EXT}" STREQUAL ".spec")
        # This is a 'ready-to-use' spec file which does not need to be CONFIGURED
          GET_FILENAME_COMPONENT(SPECFILE_NAME ${SPECFILE_PATH} NAME)
          MESSAGE(STATUS "Simple copy spec file <${SPECFILE_PATH}> --> <${RPM_ROOTDIR}/SPECS/${SPECFILE_NAME}>")
          CONFIGURE_FILE(
            ${SPECFILE_PATH} 
            ${RPM_ROOTDIR}/SPECS/${SPECFILE_NAME}
            COPYONLY)
        ELSE ("${SPECFILE_EXT}" STREQUAL ".spec")
        # This is a to-be-configured spec file
          GET_FILENAME_COMPONENT(SPECFILE_NAME ${SPECFILE_PATH} NAME_WE)
          SET(SPECFILE_NAME "${SPECFILE_NAME}.spec")
          MESSAGE(STATUS "Configuring spec file <${SPECFILE_PATH}> --> <${RPM_ROOTDIR}/SPECS/${SPECFILE_NAME}>")
          CONFIGURE_FILE(
            ${SPECFILE_PATH} 
            ${RPM_ROOTDIR}/SPECS/${SPECFILE_NAME}
            @ONLY)
        ENDIF ("${SPECFILE_EXT}" STREQUAL ".spec")
      ENDIF("${ARGV1}" STREQUAL "")
            
      ADD_CUSTOM_TARGET(${RPMNAME}_srpm
        COMMAND ${CMAKE_BUILD_TOOL} src_dist
        COMMAND ${CMAKE_COMMAND} -E copy ${SRC_DIST_DIR}.tar.gz ${RPM_ROOTDIR}/SOURCES    
        COMMAND ${RPMTools_RPMBUILD_EXECUTABLE} -bs --define=\"_topdir ${RPM_ROOTDIR}\" --buildroot=${RPM_ROOTDIR}/tmp ${RPM_ROOTDIR}/SPECS/${SPECFILE_NAME} 
        )
      
      ADD_CUSTOM_TARGET(${RPMNAME}_rpm
        COMMAND ${CMAKE_BUILD_TOOL} src_dist
        COMMAND ${CMAKE_COMMAND} -E copy ${SRC_DIST_DIR}.tar.gz ${RPM_ROOTDIR}/SOURCES    
        COMMAND ${RPMTools_RPMBUILD_EXECUTABLE} -bb --define=\"_topdir ${RPM_ROOTDIR}\" --buildroot=${RPM_ROOTDIR}/tmp ${RPM_ROOTDIR}/SPECS/${SPECFILE_NAME} 
        )  
    ENDMACRO(RPMTools_ADD_RPM_TARGETS)

  ELSE (RPMTools_RPMBUILD_FOUND)
    SET(RPMTools FALSE)
  ENDIF (RPMTools_RPMBUILD_FOUND)  
  
ENDIF (UNIX)
