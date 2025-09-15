package main

import (
	"fmt"
	"os"
	"strconv"
)

// 1. uzdevums - Pirmreizinātāju funkcijas
func factorize(n int) []int {
	var factors []int
	factor := 2

	for factor <= n {
		if n%factor == 0 {
			factors = append(factors, factor)
			n = n / factor
		} else {
			factor++
		}
	}

	return factors
}

func processCommandLineArgs(args []string) {
	for _, arg := range args {
		num, err := strconv.Atoi(arg)
		if err != nil || num < 2 {
			// Ignoer
			continue
		}

		factors := factorize(num)
		fmt.Printf("%d:", num)
		for _, factor := range factors {
			fmt.Printf(" %d", factor)
		}
		fmt.Println()
	}
}

func getNumberFromInput() (int, error) {
	var input string
	fmt.Print("Ievadiet skaitli: ")
	fmt.Scanln(&input)

	num, err := strconv.Atoi(input)
	if err != nil || num < 2 {
		return 0, fmt.Errorf("input-output error")
	}

	return num, nil
}

// 2. uzdevums - Skaitļu virkņu funkcijas

func readSequence(sequenceName string) []int {
	var sequence []int
	fmt.Printf("Ievadiet %s virkni (beidziet ar 0):\n", sequenceName)

	for {
		var input string
		fmt.Print("Ievadiet skaitli: ")
		fmt.Scanln(&input)

		num, err := strconv.Atoi(input)
		if err != nil {
			fmt.Println("Kļūda: Ievadiet veselu skaitli!")
			continue
		}

		if num == 0 {
			break
		}

		sequence = append(sequence, num)
	}

	return sequence
}

func findUniqueElements(first, second []int) []int {
	var unique []int

	for _, firstNum := range first {
		found := false
		for _, secondNum := range second {
			if firstNum == secondNum {
				found = true
				break
			}
		}
		if !found {
			unique = append(unique, firstNum)
		}
	}

	return unique
}

func printSequence(sequence []int, description string) {
	fmt.Printf("%s: ", description)
	for i, num := range sequence {
		if i > 0 {
			fmt.Print(" ")
		}
		fmt.Print(num)
	}
	fmt.Println()
}

func main() {
	fmt.Println("1. uzdevums - Pirmreizinātāju sadalīšana")
	fmt.Println("2. uzdevums - Virkņu salīdzināšana")
	fmt.Println()

	var choice string
	fmt.Print("Izvēlieties uzdevumu (1 vai 2): ")
	fmt.Scanln(&choice)

	switch choice {
	case "1":
		fmt.Println("\n1. uzdevums")

		args := os.Args[1:]

		if len(args) > 0 {
			fmt.Println("Apstrādāju komandrindas parametrus:")
			processCommandLineArgs(args)
		} else {
			fmt.Println("Komandrindas parametri nav norādīti.")
			num, err := getNumberFromInput()
			if err != nil {
				fmt.Println(err.Error())
				return
			}

			factors := factorize(num)
			fmt.Printf("%d:", num)
			for _, factor := range factors {
				fmt.Printf(" %d", factor)
			}
			fmt.Println()
		}

	case "2":
		fmt.Println("\n2. uzdevums")

		first := readSequence("pirmo")
		second := readSequence("otro")

		// Atrast unikālos elementus
		unique := findUniqueElements(first, second)

		fmt.Println("\nRezultāti:")
		printSequence(first, "Pirmā virkne")
		printSequence(second, "Otrā virkne")
		printSequence(unique, "Elementi, kas ir pirmajā virknē, bet nav otrajā")

	default:
		fmt.Println("Nederīga izvēle! Lūdzu izvēlieties 1 vai 2.")
	}
}
