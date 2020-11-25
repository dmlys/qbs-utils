import qbs
import qbs.Environment

Module
{
	Depends { name: "cpp" }

	cpp.cxxLanguageVersion : "c++17"
	//cpp.minimumWindowsVersion: "7.2"
	//cpp.windowsApiCharacterSet: "unicode" // actually default

	cpp.driverFlags:
	{
		var flags = project.additionalDriverFlags || []

		var envDefines = Environment.getEnv("QBS_EXTRA_DRIVER_FLAGS")
		if (envDefines)
		{
			envFlags = envFlags.split(" ").filter(Boolean)
			flags = flags.concat(envFlags)
		}

		if (qbs.toolchain.contains("gcc") || qbs.toolchain.contains("clang"))
			flags.push("-pthread")

		//if (qbs.toolchain.contains("gcc") || qbs.toolchain.contains("clang"))
		//	flags.concat(["-pthread", "-march=native"])

		return flags
	}

	cpp.driverLinkerFlags:
	{
		var flags = cpp.additionalDriverLinkerFlags || []

		var envDefines = Environment.getEnv("QBS_EXTRA_DRIVER_LINKER_FLAGS")
		if (envDefines)
		{
			envFlags = envFlags.split(" ").filter(Boolean)
			flags = flags.concat(envFlags)
		}

		if (qbs.toolchain.contains("mingw"))
			// this will add linking for libssp under mingw, through not static(maybe depends on -Bstatic state)
			flags.push("-fstack-protector")

		return flags
	}


	cpp.defines:
	{
		var defs = project.additionalDefines || []

		var envDefines = Environment.getEnv("QBS_EXTRA_DEFINES")
		if (envDefines)
		{
			var splitter = new RegExp(" " + "|" + qbs.pathListSeparator)
			envDefines = envDefines.split(splitter).filter(Boolean)
			defs = defs.uniqueConcat(envDefines)
		}
		
		if (qbs.toolchain.contains("msvc"))
		{
			defs.push("_SILENCE_CXX17_ITERATOR_BASE_CLASS_DEPRECATION_WARNING")
			defs.push("_SILENCE_CXX17_RESULT_OF_DEPRECATION_WARNING")
			defs.push("_SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING")
			defs.push("_SILENCE_CXX17_OLD_ALLOCATOR_MEMBERS_DEPRECATION_WARNING")
			//defs.push("_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS")

			//defs.push("_HAS_AUTO_PTR_ETC")
			//defs.push("_HAS_OLD_IOSTREAMS_MEMBERS")

			defs = defs.uniqueConcat(["_SCL_SECURE_NO_WARNINGS", ])
		}

		//if (qbs.toolchain.contains("mingw") || qbs.toolchain.contains("msvc"))
		//	defs = defs.uniqueConcat(["_WIN32_WINNT=0x0600"])

		if (qbs.toolchain.contains("gcc") && cpp.optimization == 'fast')
			defs.push("_FORTIFY_SOURCE=2")

		return defs
	}

	cpp.cxxFlags:
	{
		var flags = cpp.additionalCxxFlags || []

		var envFlags = Environment.getEnv("QBS_EXTRA_CXXFLAGS")
		if (envFlags)
		{
			envFlags = envFlags.split(" ").filter(Boolean)
			flags = flags.concat(envFlags)
		}

		if (qbs.toolchain.contains("gcc") || qbs.toolchain.contains("clang"))
		{
			//flags.push("-Wsuggest-override")
			flags.push("-Wno-extra")
			flags.push("-Wno-unused-parameter")
			flags.push("-Wno-unused-function")
			//flags.push("-Wno-unused-local-typedefs")
			//flags.push("-Wno-sign-compare")
			flags.push("-Wno-implicit-fallthrough")
			flags.push("-Wno-deprecated-declarations")
		}

		if (qbs.toolchain.contains("msvc"))
		{
			flags = flags.concat("/FI", "ciso646")
			
			flags.push("/w34239") // turn on on 3rd level warning C4239: nonstandard extension used : 'argument'
			flags.push("/wd4458") // warning C4458: declaration of '<var>' hides class member
			flags.push("/wd4457") // warning C4457: declaration of '<var>' hides function parameter
			flags.push("/wd4456") // warning C4456: declaration of '<var>' hides previous local declaration
		}

		return flags
	}

	cpp.cFlags:
	{
		var flags = cpp.additionalCFlags || []

		var envFlags = Environment.getEnv("QBS_EXTRA_CFLAGS")
		if (envFlags)
		{
			envFlags = envFlags.split(" ").filter(Boolean)
			flags = flags.concat(envFlags)
		}

		return flags
	}


	cpp.systemIncludePaths:
	{
		var includes = []
		var envIncludes = Environment.getEnv("QBS_EXTRA_SYSTEM_INCLUDES")
		if (envIncludes)
		{
			envIncludes = envIncludes.split(qbs.pathListSeparator).filter(Boolean)
			includes = includes.uniqueConcat(envIncludes)
		}

		return includes	
	}

	cpp.includePaths:
	{
		var includes = []
		var envIncludes = Environment.getEnv("QBS_EXTRA_INCLUDES")
		if (envIncludes)
		{
			envIncludes = envIncludes.split(qbs.pathListSeparator).filter(Boolean)
			includes = includes.uniqueConcat(envIncludes)
		}

		return includes
	}

	cpp.libraryPaths:
	{
		var libPaths = []
		var envLibPaths = Environment.getEnv("QBS_EXTRA_LIBPATH")
		if (envLibPaths)
		{
			envLibPaths = envLibPaths.split(qbs.pathListSeparator).filter(Boolean)
			libPaths = libPaths.uniqueConcat(envLibPaths)
		}

		return libPaths
	}
} 
