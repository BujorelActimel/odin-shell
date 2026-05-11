package main

import "core:bufio"
import "core:fmt"
import "core:os"

main :: proc() {
	scanner: bufio.Scanner
	stdin := os.to_stream(os.stdin)

	bufio.scanner_init(&scanner, stdin)
	defer bufio.scanner_destroy(&scanner)

	for {
		input := prompt_user(&scanner)
		fmt.printfln("%s: command not found", input)
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
