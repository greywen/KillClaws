package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	"github.com/greywen/KillClaws/internal/killer"
	"github.com/greywen/KillClaws/internal/report"
	"github.com/greywen/KillClaws/internal/scanner"
	"github.com/greywen/KillClaws/internal/types"
)

var version = "dev"

func main() {
	// Flags
	scanCmd := flag.NewFlagSet("scan", flag.ExitOnError)
	scanJSON := scanCmd.Bool("json", false, "Output as JSON")

	yes := flag.Bool("yes", false, "Skip confirmation prompt")
	dryRun := flag.Bool("dry-run", false, "Show what would be removed without doing it")
	verbose := flag.Bool("verbose", false, "Show detailed output")
	only := flag.String("only", "", "Only uninstall specified products (comma-separated)")
	exclude := flag.String("exclude", "", "Exclude specified products (comma-separated)")
	showVersion := flag.Bool("version", false, "Show version")

	// Handle subcommands
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "scan":
			scanCmd.Parse(os.Args[2:])
			runScan(*scanJSON)
			return
		case "version":
			fmt.Printf("killclaws %s\n", version)
			return
		case "help", "-h", "--help":
			printUsage()
			return
		}
	}

	// Parse main flags
	flag.Parse()

	if *showVersion {
		fmt.Printf("killclaws %s\n", version)
		return
	}

	// Main uninstall flow
	runUninstall(*yes, *dryRun, *verbose, *only, *exclude)
}

func runScan(asJSON bool) {
	result := scanner.Scan()
	if asJSON {
		if err := report.PrintScanJSON(result); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	} else {
		report.PrintScan(result)
	}

	if result.DetectedCount() > 0 {
		os.Exit(0)
	}
	os.Exit(0)
}

func runUninstall(yes, dryRun, verbose bool, only, exclude string) {
	// Step 1: Scan
	var result = scanner.Scan()
	if only != "" {
		result = scanner.ScanOnly(splitAndTrim(only))
	} else if exclude != "" {
		result = scanner.ScanExclude(splitAndTrim(exclude))
	}

	if result.DetectedCount() == 0 {
		fmt.Println("\n🎉 No Claw products detected. System is already clean!")
		return
	}

	// Step 2: Show findings
	report.PrintScan(result)

	// Step 3: Dry run?
	if dryRun {
		report.PrintDryRun(result)
		return
	}

	// Step 4: Confirm
	if !yes {
		fmt.Print("  Proceed with removal? [y/N] ")
		var answer string
		fmt.Scanln(&answer)
		answer = strings.TrimSpace(strings.ToLower(answer))
		if answer != "y" && answer != "yes" {
			fmt.Println("  Aborted.")
			return
		}
	}

	fmt.Println("\n🧹 Removing Claw products...")

	// Step 5: Try official OpenClaw uninstall first
	for _, p := range result.Products {
		if p.Name == "OpenClaw" && p.Detected {
			killer.TryOfficialUninstall(verbose)
			break
		}
	}

	// Step 6: Kill everything
	var results []types.UninstallResult
	for _, p := range result.Products {
		if !p.Detected {
			continue
		}
		if verbose {
			fmt.Printf("\n  Processing: %s\n", p.Name)
		}
		r := killer.Kill(p, verbose)
		results = append(results, r)
	}

	// Step 7: Verify
	if verbose {
		fmt.Println("\n  Verifying removal...")
	}
	verify := scanner.Scan()
	if verify.DetectedCount() > 0 {
		fmt.Println("\n  ⚠️  Some products still detected after removal:")
		report.PrintScan(verify)
	}

	// Step 8: Report
	report.PrintUninstallResults(results)
}

func splitAndTrim(s string) []string {
	parts := strings.Split(s, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			result = append(result, p)
		}
	}
	return result
}

func printUsage() {
	fmt.Println(`KillClaws — One command to remove all Claw products

Usage:
  killclaws              Scan and remove all detected Claw products (interactive)
  killclaws scan         Scan only, show what's installed
  killclaws scan --json  Scan and output as JSON
  killclaws --yes        Remove all without confirmation
  killclaws --dry-run    Show what would be removed
  killclaws --version    Show version
  killclaws help         Show this help

Flags:
  --yes            Skip confirmation prompt
  --dry-run        Preview removal without modifying anything
  --verbose        Show detailed output
  --only <list>    Only remove specified products (comma-separated)
  --exclude <list> Skip specified products (comma-separated)

Products detected:
  OpenClaw, QClaw, WorkBuddy, ZeroClaw, PicoClaw, KimiCLI

Examples:
  killclaws                          # Interactive: scan → confirm → remove
  killclaws --yes                    # Remove all, no prompt
  killclaws --dry-run                # Preview only
  killclaws --only openclaw          # Only remove OpenClaw
  killclaws --only openclaw,qclaw    # Remove OpenClaw and QClaw
  killclaws --exclude zeroclaw       # Remove all except ZeroClaw
  killclaws scan                     # Just show what's installed
  killclaws scan --json              # JSON output for automation`)
}
