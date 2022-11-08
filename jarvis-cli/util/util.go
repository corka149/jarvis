package util

import (
	"bufio"
	"fmt"
	"os"
)

func RequestUser(attribute string) (string, error) {
	fmt.Printf("Input %s > ", attribute)
	reader := bufio.NewReader(os.Stdin)
	return reader.ReadString('\n')
}
