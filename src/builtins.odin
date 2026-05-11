#+feature dynamic-literals

package main

import "core:fmt"
import "core:os"
import "core:strings"

Builtin_Command :: proc(command: string, args: []string) -> Maybe(int)

builtin_commands := map[string]Builtin_Command {
	"exit" = command_exit,
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
	path := os.get_env("PATH", context.allocator)

	if command_to_check in builtin_commands {
		fmt.printfln("%s is a shell builtin", command_to_check)
	} else {
		result := search_exe_binary(path, command_to_check)
		if bin_path, ok := result.?; ok {
			fmt.printfln("%s is %s", command_to_check, bin_path)
		} else {
			fmt.printfln("%s: not found", command_to_check)
		}
	}

	return nil
}

command_execute :: proc(command: string, args: []string) -> Maybe(int) {
	path := os.get_env("PATH", context.allocator)

	result := search_exe_binary(path, command)

	command_slice := [dynamic]string{command}
	for arg in args {
		append_elem(&command_slice, arg)
	}

	if bin_path, ok := result.?; ok {
		process := os.Process_Desc {
			working_dir = "",
			command     = command_slice[:],
		}

		state, stdout, stderr, err := os.process_exec(process, context.allocator)

		if err != nil {
			fmt.eprintfln("Error: %s", err)
		}

		fmt.print(string(stdout))
		fmt.eprint(string(stderr))

		// if state.exit_code != 0 {
		// 	return state.exit_code
		// }

		return nil
	} else {
		return command_not_found(command, args)
	}
}

search_exe_binary :: proc(path: string, binary_name: string) -> Maybe(string) {
	dirs := strings.split(path, ":")

	for dir in dirs {
		full_path := strings.join({dir, binary_name}, "/")

		info, err := os.stat(full_path, allocator = context.allocator)
		if err != nil {
			continue
		}

		// skip non_executables
		if os.Permission_Flag.Execute_User not_in info.mode {
			continue
		}

		return full_path
	}

	return nil
}
