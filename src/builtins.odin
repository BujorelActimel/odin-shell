package main

import "core:fmt"
import "core:strings"

command_echo :: proc(args: []string) {
	out, _ := strings.join(args, " ")
	fmt.printfln(out)
}
