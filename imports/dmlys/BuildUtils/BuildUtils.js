function make_winlibs()
{
	var qbs = arguments[0]
	var cpp = arguments[1]
	var libs = []
	
	for (var i = 2; i < arguments.length; ++i)
	{
		var item = arguments[i]
		if (Array.isArray(item))
			libs = libs.concat(make_winlibs.apply(null, [qbs, cpp].concat(item)))
		else
			libs.push(make_winlib(qbs, cpp, item))
	}
	
	return libs
}

function make_winlib(qbs, cpp, libname)
{
	libname = String(libname)
	
	var ext_point = libname.lastIndexOf('.')
	var ext  = ext_point >= 0 ? libname.substring(ext_point) : ""
	var name = ext_point >= 0 ? libname.substring(0, ext_point) : libname
	
	name += "-mt"
	
	var is_debug = qbs.enableDebugCode
	var is_static_runtime = cpp.runtimeLibrary == "static"
	
	if (is_static_runtime)
		name += is_debug ? "-sgd" : "-gd"
	else
		name += is_debug ? "-gd" : ""
	
	if (ext) name = name + ext
	
	return name;
}

function make_libs()
{
	var qbs = arguments[0]
	var cpp = arguments[1]
	
	if (qbs.toolchain.contains('msvc'))
		return make_winlibs.apply(null, arguments)
	else {
		var libs = []
		for (var i = 2; i < arguments.length; ++i)
		{
			var item = arguments[i]
			if (Array.isArray(item))
				libs = make_libs.apply(null, [qbs, cpp].concat.concat(item))
			else
				libs.push(String(item))
		}

		return libs
	}
}
