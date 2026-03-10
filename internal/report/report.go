package report

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/greywen/KillClaws/internal/types"
)

// PrintScan outputs the scan result in human-readable format.
func PrintScan(result types.ScanResult) {
	fmt.Printf("\n🔍 KillClaws Scan Results (%s)\n", result.Platform)
	fmt.Println(strings.Repeat("─", 60))

	detected := 0
	for _, p := range result.Products {
		if p.Detected {
			detected++
			fmt.Printf("\n  ✅ %s\n", p.Name)
			if len(p.Paths) > 0 {
				fmt.Printf("     Paths:     %s\n", strings.Join(p.Paths, ", "))
			}
			if len(p.Services) > 0 {
				fmt.Printf("     Services:  %s\n", strings.Join(p.Services, ", "))
			}
			if len(p.Processes) > 0 {
				fmt.Printf("     Processes: %d running\n", len(p.Processes))
			}
			if len(p.Packages) > 0 {
				pkgs := make([]string, 0, len(p.Packages))
				for _, pkg := range p.Packages {
					pkgs = append(pkgs, pkg.Manager+":"+pkg.Name)
				}
				fmt.Printf("     Packages:  %s\n", strings.Join(pkgs, ", "))
			}
			if p.DiskUsage > 0 {
				fmt.Printf("     Disk:      %s\n", formatBytes(p.DiskUsage))
			}
		} else {
			fmt.Printf("\n  ⬜ %s — not detected\n", p.Name)
		}
	}

	fmt.Println(strings.Repeat("─", 60))
	if detected == 0 {
		fmt.Println("  🎉 No Claw products detected. System is clean!")
	} else {
		fmt.Printf("  Found %d product(s). Run `killclaws` to remove.\n", detected)
	}
	fmt.Println()
}

// PrintScanJSON outputs the scan result as JSON.
func PrintScanJSON(result types.ScanResult) error {
	data, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		return err
	}
	fmt.Println(string(data))
	return nil
}

// PrintUninstallResults outputs the uninstall results.
func PrintUninstallResults(results []types.UninstallResult) {
	fmt.Println()
	fmt.Println(strings.Repeat("─", 60))
	fmt.Println("🧹 KillClaws Uninstall Summary")
	fmt.Println(strings.Repeat("─", 60))

	var totalFreed int64
	allSuccess := true
	for _, r := range results {
		if r.Product == "" {
			continue
		}
		status := "✅"
		if !r.Success {
			status = "⚠️"
			allSuccess = false
		}
		fmt.Printf("\n  %s %s\n", status, r.Product)
		if len(r.RemovedPaths) > 0 {
			fmt.Printf("     Removed %d path(s)\n", len(r.RemovedPaths))
		}
		if len(r.StoppedProcs) > 0 {
			fmt.Printf("     Stopped %d process(es)\n", len(r.StoppedProcs))
		}
		if len(r.RemovedSvcs) > 0 {
			fmt.Printf("     Removed %d service(s)\n", len(r.RemovedSvcs))
		}
		if r.FreedBytes > 0 {
			fmt.Printf("     Freed %s\n", formatBytes(r.FreedBytes))
		}
		for _, e := range r.Errors {
			fmt.Printf("     ❌ %s\n", e)
		}
		totalFreed += r.FreedBytes
	}

	fmt.Println(strings.Repeat("─", 60))
	if allSuccess {
		fmt.Println("  ✅ All products removed successfully!")
	} else {
		fmt.Println("  ⚠️  Some items had errors. Run with --verbose for details.")
	}
	if totalFreed > 0 {
		fmt.Printf("  💾 Total freed: %s\n", formatBytes(totalFreed))
	}

	// Reminders
	fmt.Println()
	fmt.Println("  📌 Manual steps you may still need:")
	fmt.Println("     • Revoke API keys (OpenAI, Anthropic, Moonshot, etc.)")
	fmt.Println("     • Disconnect chat platforms (WhatsApp, Telegram, Discord bots)")
	fmt.Println("     • Remove OAuth authorizations in platform settings")
	fmt.Println("     • Remove browser extensions (OpenClaw Chrome extension)")
	fmt.Println()
}

// PrintDryRun outputs what would be removed.
func PrintDryRun(result types.ScanResult) {
	fmt.Println()
	fmt.Println("🔍 DRY RUN — nothing will be modified")
	fmt.Println(strings.Repeat("─", 60))

	for _, p := range result.Products {
		if !p.Detected {
			continue
		}
		fmt.Printf("\n  Would remove: %s\n", p.Name)
		for _, path := range p.Paths {
			fmt.Printf("     [DELETE] %s\n", path)
		}
		for _, svc := range p.Services {
			fmt.Printf("     [STOP]   %s\n", svc)
		}
		for _, pkg := range p.Packages {
			fmt.Printf("     [UNINSTALL] %s:%s\n", pkg.Manager, pkg.Name)
		}
		if len(p.Processes) > 0 {
			fmt.Printf("     [KILL]   %d process(es)\n", len(p.Processes))
		}
	}
	fmt.Println(strings.Repeat("─", 60))
	fmt.Println()
}

func formatBytes(b int64) string {
	const (
		kb = 1024
		mb = kb * 1024
		gb = mb * 1024
	)
	switch {
	case b >= gb:
		return fmt.Sprintf("%.1f GB", float64(b)/float64(gb))
	case b >= mb:
		return fmt.Sprintf("%.1f MB", float64(b)/float64(mb))
	case b >= kb:
		return fmt.Sprintf("%.1f KB", float64(b)/float64(kb))
	default:
		return fmt.Sprintf("%d B", b)
	}
}
