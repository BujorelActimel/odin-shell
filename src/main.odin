package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	exit_code := 0
	defer os.exit(exit_code)

	scanner: bufio.Scanner
	stdin := os.to_stream(os.stdin)

	bufio.scanner_init(&scanner, stdin)
	defer bufio.scanner_destroy(&scanner)

	for {
		input := prompt_user(&scanner)

		maybe_code := evaluate(input)

		if code, ok := maybe_code.?; ok {
			exit_code = code
			break
		}
	}
}

// returns the exit code or nil
evaluate :: proc(input: string) -> Maybe(int) {
	input_array, _ := strings.split(input, " ")
	command, args := input_array[0], input_array[1:]
	switch command {
	case "exit":
		if len(args) == 0 {
			return 0
		}
		return nil

	case "echo":
		command_echo(args)
		return nil

	case:
		fmt.printfln("%s: command not found", input)
		return nil

	}
}

prompt_user :: proc(scanner: ^bufio.Scanner) -> string {
	fmt.printf("$ ")

	if !bufio.scanner_scan(scanner) {
		return ""
	}

	if err := bufio.scanner_error(scanner); err != nil {
		fmt.eprintln("error scanning input: %v", err)
		return ""
	}

	return bufio.scanner_text(scanner)
}
