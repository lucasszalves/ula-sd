#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# backup, sem apagar
mkdir -p ../work_backup
mv work-obj*.cf ../work_backup/ 2>/dev/null || true
echo "work backup -> ../work_backup/"

# arquivos fonte
files=( *.vhdl )
maxpass=12

echo "Starting iterative compile..."

for pass in $(seq 1 $maxpass); do
    echo "Pass $pass, files remaining: ${#files[@]}"
    made_progress=false
    remaining=()
    for f in "${files[@]}"; do
        printf " try compile %-40s ... " "$f"
        if ghdl -a --std=08 "$f" 2>/tmp/ghdl_err; then
            echo "OK"
            made_progress=true
        else
            echo "FAIL"
            head -n4 /tmp/ghdl_err | sed 's/^/ /'
            remaining+=( "$f" )
        fi
    done

    files=( "${remaining[@]}" )

    if [ ${#files[@]} -eq 0 ]; then
        echo "All sources analyzed successfully."
        break
    fi

    if ! $made_progress; then
        echo "No progress on this pass. Likely unresolved dependencies or duplicate/obsolete definitions."
        echo "Remaining files:"
        printf ' %s\n' "${files[@]}"
        exit 1
    fi
done

# elaborate & run testbench
ghdl -e --std=08 tb_ula
ghdl -r --std=08 tb_ula --vcd=tb_ula.vcd --stop-time=100us

echo "Simulation finished, waveform: tb_ula.vcd"