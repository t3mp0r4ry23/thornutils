use os;
use fmt;
use getopt;

export fn main() void = {
	const cmd = getopt::parse(os::args,
		"Print certain system information. Defaults to -s.",
		('a', "behave as if all options were specified"),
		('m', "prints the name of the hardware type"),
		('n', "prints the \"node\" (usually hostname)"),
		('r', "prints the current release"),
		('s', "prints the os name"),
		('v', "prints the current version")
	);
	defer getopt::finish(&cmd);

	if (len(os::args) == 1) {
		fmt::println(os::sysname())!;
	} else {
		for (let opt .. cmd.opts) {
			switch (opt.0) {
			case 'a' => {
				fmt::print(os::sysname(), os::hostname(), os::release(), os::version(), os::arch_name(os::architecture()))!;
				break;
			};
			case 'm' => 
				fmt::print(os::arch_name(os::architecture()))!;
			case 'n' =>
				fmt::print(os::hostname())!;
			case 'r' =>
				fmt::print(os::release())!;
			case 's' =>
				fmt::print(os::sysname())!;
			case 'v' =>
				fmt::print(os::version())!;
			case => abort();
			};
		};
		fmt::println("")!;
	};
};
