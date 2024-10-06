use fmt;
use os;

export fn main() void = {
	for (let item .. os::args[1..]) {
		fmt::printfln("{}", item)!;
	};
};
