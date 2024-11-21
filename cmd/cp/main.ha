use errors;
use io;
use fs;
use fmt;
use strings;
use os;
use time;
use getopt;

export fn main() void = {
	//TODO: const cmd = getopt::parse(os::args, )
	const dest_stat = match(os::stat(os::args[len(os::args)-1])) {
	case let fstat: fs::filestat =>
		yield fstat;
	case errors::noaccess => {
		fmt::fatalf("Can not open {}: Access denied.", os::args[len(os::args)-1]);
	};
	case fs::error =>
		//don't worry about it
		yield fs::filestat {
			mask = 0,
			mode = 0,
			uid = 0,
			gid = 0,
			sz = 0,
			inode = 0,
			atime = time::from_unix(0),
			mtime = time::from_unix(0),
			ctime = time::from_unix(0),
		};
	};
	let i = 1z;

	if (fs::isdir(dest_stat.mode)) {
		for (i < len(os::args) - 1; i += 1) {
			const src_path = strings::split(os::args[i], "/");
			const src_name = src_path[len(src_path)-1];
			const dest = strings::concat(os::resolve(os::args[len(os::args)-1]), "/", src_name);
			defer free(dest);
			free(src_path);

			copy(dest, os::args[i]);
		};
	} else if (len(os::args) == 3) {
		copy(os::args[2], os::args[1]);
	};
};

fn open_or_create(path: str) io::file = {
	if (os::exists(path)) {
		return os::open(path, 1 | 512)!;
	} else {
		return os::create(path, 384 | 48 | 4)!;
	};
};

fn copy(dest: str, src: str) void = {
	if (os::resolve(dest) == os::resolve(src)) {
		fmt::fprintfln(os::stderr, "Can not copy {} to itself.", src)!;
	} else {
		const src = os::open(src)!;
		defer io::close(src)!;

		const dest = open_or_create(dest);
		defer io::close(dest)!;

		io::copy(dest, src)!;
	};
};
