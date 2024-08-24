# Specify regular expression implementation
find_package(PCRE)

if(REGEX_BACKEND STREQUAL "")
	check_symbol_exists(regcomp_l "regex.h;xlocale.h" HAVE_REGCOMP_L)

	if(HAVE_REGCOMP_L)
		if(CMAKE_SYSTEM_NAME MATCHES "iOS")
			# 'regcomp_l' has been explicitly marked unavailable on iOS_SDK
			# /usr/include/xlocale/_regex.h:34:5: 
			# int	regcomp_l(regex_t * __restrict, const char * __restrict, int,
			# locale_t __restrict)
			# __OSX_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA);
			set(REGEX_BACKEND "regcomp")
		else()
			set(REGEX_BACKEND "regcomp_l")
		endif()
	elseif(PCRE_FOUND)
		set(REGEX_BACKEND "pcre")
	else()
		set(REGEX_BACKEND "builtin")
	endif()
endif()

if(REGEX_BACKEND STREQUAL "regcomp_l")
	add_feature_info(regex ON "using system regcomp_l")
	set(GIT_REGEX_REGCOMP_L 1)
elseif(REGEX_BACKEND STREQUAL "pcre2")
	find_package(PCRE2)

	if(NOT PCRE2_FOUND)
		MESSAGE(FATAL_ERROR "PCRE2 support was requested but not found")
	endif()

	add_feature_info(regex ON "using system PCRE2")
	set(GIT_REGEX_PCRE2 1)

	list(APPEND LIBGIT2_SYSTEM_INCLUDES ${PCRE2_INCLUDE_DIRS})
	list(APPEND LIBGIT2_SYSTEM_LIBS ${PCRE2_LIBRARIES})
	list(APPEND LIBGIT2_PC_REQUIRES "libpcre2-8")
elseif(REGEX_BACKEND STREQUAL "pcre")
	add_feature_info(regex ON "using system PCRE")
	set(GIT_REGEX_PCRE 1)

	list(APPEND LIBGIT2_SYSTEM_INCLUDES ${PCRE_INCLUDE_DIRS})
	list(APPEND LIBGIT2_SYSTEM_LIBS ${PCRE_LIBRARIES})
	list(APPEND LIBGIT2_PC_REQUIRES "libpcre")
elseif(REGEX_BACKEND STREQUAL "regcomp")
	add_feature_info(regex ON "using system regcomp")
	set(GIT_REGEX_REGCOMP 1)
elseif(REGEX_BACKEND STREQUAL "builtin")
	add_feature_info(regex ON "using bundled PCRE")
	set(GIT_REGEX_BUILTIN 1)

	add_subdirectory("${PROJECT_SOURCE_DIR}/deps/pcre" "${PROJECT_BINARY_DIR}/deps/pcre")
	list(APPEND LIBGIT2_DEPENDENCY_INCLUDES "${PROJECT_SOURCE_DIR}/deps/pcre")
	list(APPEND LIBGIT2_DEPENDENCY_OBJECTS $<TARGET_OBJECTS:pcre>)
else()
	message(FATAL_ERROR "The REGEX_BACKEND option provided is not supported")
endif()
