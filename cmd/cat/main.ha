use errors;
use fmt;
use fs;
use io;
use os;
use memio;
use strings;

export fn main() void = {
	const buffer = &memio::dynamic();
	defer io::close(buffer)!;
	let bufsize = 0z;
	
	if (len(os::args) <= 1) {
		io::copy(os::stdout, os::stdin)!;
	} else if (os::args[1] == "-u") {
		let i = 2z;
		for(i < len(os::args); i += 1) {
			if (os::args[i] == "-") {
				io::copy(os::stdout, os::stdin)!;
			} else {
				if (fs::isdir((os::stat(os::args[i]) as fs::filestat).mode)) {
					fmt::fatalf("Can not cat {}: is a directory.", os::args[i]);
				} else {
					const file = match(os::open(os::args[i])) {
					case let file: io::file =>
						yield file;
					case errors::noaccess =>
						fmt::fatalf("Can not cat {}: Access denied.", os::args[i]);
					case let err: fs::error =>
						fmt::fatalf("Can not cat {}: {}", os::args[i], fs::strerror(err));
					};
					defer io::close(file)!;
					io::copy(os::stdout, file)!;
				};
			};
		};
	} else {
		let i = 1z;
		for(i < len(os::args); i += 1) {
			if (os::args[i] == "-") {
				const temp = io::drain(os::stdin)!;
				memio::concat(buffer, strings::fromutf8_unsafe(temp))!;
			} else {
				if (fs::isdir((os::stat(os::args[i]) as fs::filestat).mode)) {
					fmt::fatalf("Can not cat {}: is a directory.", os::args[i]);
				} else {
					const file = match(os::open(os::args[i])) {
					case let file: io::file =>
						yield file;
					case errors::noaccess =>
						fmt::fatalf("Can not cat {}: Access denied.", os::args[i]);
					case let err: fs::error =>
						fmt::fatalf("Can not cat {}: {}", os::args[i], fs::strerror(err));
					};
					defer io::close(file)!;
					const temp = io::drain(file)!;
					memio::concat(buffer, strings::fromutf8_unsafe(temp))!;
				};
			};
		};
		io::write(os::stdout, memio::buffer(buffer))!;
	};
};
