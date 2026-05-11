#+feature dynamic-literals

package main

import "core:fmt"
import "core:strings"

Builtin_Command :: proc(command: string, args: []string) -> Maybe(int)

builtin_commands := map[string]Builtin_Command {
	"exit" = command_echo,
	"echo" = command_echo,
	"type" = command_type,
}

command_not_found :: proc(command: string, args: []string) -> Maybe(int) {
	out := strings.join(args, " ")
	out = strings.join({command, out}, " ")
	out = strings.trim(out, " ")
	fmt.printfln("%s: command not found", out)
	return nil
}

command_exit :: proc(command: string, args: []string) -> Maybe(int) {
	if len(args) == 0 {
		return 0
	}

	return command_not_found(command, args)
}

command_echo :: proc(_: string, args: []string) -> Maybe(int) {
	out, _ := strings.join(args, " ")
	fmt.println(out)
	return nil
}

command_type :: proc(command: string, args: []string) -> Maybe(int) {
	if len(args) == 0 {
		return nil
	}
	if len(args) > 1 {
		return command_not_found(command, args)
	}

	command_to_check := args[0]
	if command_to_check in builtin_commands {
		fmt.printfln("%s is a shell builtin", command_to_check)
	} else {
		fmt.printfln("%s: not found", command_to_check)
	}

	return nil
}
