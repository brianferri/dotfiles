#!/usr/bin/env bash

RATE_EUR_PER_KWH=0.28
SAMPLE_S=1

bat=""
for b in /sys/class/power_supply/BAT*; do
    [[ -r "$b/capacity" ]] && { bat=$b; break; }
done

cap=""; status="Unknown"
[[ -n "$bat" ]] && { cap=$(<"$bat/capacity"); status=$(<"$bat/status"); }

body=""; basis=""

if [[ "$status" == "Discharging" && -n "$bat" ]]; then
    # Discharge power in µW is the true whole-system draw: power_now where the
    # pack exposes it, else `voltage * current`.
    uw=""
    if [[ -s "$bat/power_now" ]]; then
        uw=$(<"$bat/power_now")
    elif [[ -r "$bat/voltage_now" && -r "$bat/current_now" ]]; then
        uw=$(awk -v v="$(<"$bat/voltage_now")" -v i="$(<"$bat/current_now")" 'BEGIN { printf "%.0f", v * i / 1e6 }')
    fi
    if [[ -n "$uw" ]]; then
        basis=$(awk -v u="$uw" 'BEGIN { printf "%.1f", u / 1e6 }')
        body=$(printf '\n\nDraw\t%s W' "$basis")
    fi
else
    # On AC the battery reads ~0, so estimate from CPU + GPU sensors. This is a
    # lower bound - display, storage, and peripherals are not measured (the >=).

    # CPU via RAPL: energy-counter delta over SAMPLE_S. Root-readable only, so n/a
    # until a powercap udev rule is installed. Prefer psys, else sum packages.
    rapl=()
    for d in /sys/class/powercap/intel-rapl:*; do
        [[ -r "$d/name" ]] || continue
        case "$(<"$d/name")" in
            psys) rapl=("$d"); break ;;
            package-*) rapl+=("$d") ;;
        esac
    done
    rapl_sum() { local s=0 v d; for d in "${rapl[@]}"; do v=$(cat "$d/energy_uj" 2>/dev/null) || return 1; [[ -z "$v" ]] && return 1; s=$(( s + v )); done; echo "$s"; }
    cpu_w="n/a"
    if (( ${#rapl[@]} )) && e1=$(rapl_sum); then
        span=0; for d in "${rapl[@]}"; do span=$(( span + $(<"$d/max_energy_range_uj") )); done
        sleep "$SAMPLE_S"
        e2=$(rapl_sum)
        delta=$(( e2 - e1 )); (( delta < 0 )) && delta=$(( delta + span ))
        cpu_w=$(awk -v d="$delta" -v t="$SAMPLE_S" 'BEGIN { printf "%.1f", d / 1e6 / t }')
    fi

    # GPU: NVIDIA (only while already awake - querying wakes a suspended dGPU),
    # plus any amdgpu/i915/xe hwmon exposing average power.
    gpu_w=""; gtot=0; seen=0
    if command -v nvidia-smi >/dev/null 2>&1; then
        awake=1
        for rs in /sys/bus/pci/drivers/nvidia/*/power/runtime_status; do
            [[ -r "$rs" ]] || continue
            [[ "$(<"$rs")" == active ]] && { awake=1; break; } || awake=0
        done
        seen=1
        if (( awake )); then
            nv=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | awk '{ s += $1 } END { if (NR) printf "%.1f", s }')
            [[ -n "$nv" ]] && gtot=$(awk -v a="$gtot" -v b="$nv" 'BEGIN { printf "%.1f", a + b }')
        fi
    fi
    for h in /sys/class/hwmon/hwmon*; do
        [[ -r "$h/name" ]] || continue
        case "$(<"$h/name")" in amdgpu|i915|xe) ;; *) continue ;; esac
        p=""
        [[ -r "$h/power1_average" ]] && p=$(<"$h/power1_average")
        [[ -z "$p" && -r "$h/power1_input" ]] && p=$(<"$h/power1_input")
        [[ -n "$p" ]] && { gtot=$(awk -v a="$gtot" -v p="$p" 'BEGIN { printf "%.1f", a + p / 1e6 }'); seen=1; }
    done
    (( seen )) && gpu_w=$gtot

    cpu_num=$cpu_w; [[ "$cpu_num" == "n/a" ]] && cpu_num=0
    basis=$(awk -v c="$cpu_num" -v g="${gpu_w:-0}" 'BEGIN { printf "%.1f", c + g }')
    body=$(printf '\n\nCPU\t%s W\nGPU\t%s W\nEst.\t≥%s W (partial)' "$cpu_w" "${gpu_w:-n/a}" "$basis")
fi

cost_line=""
if [[ -n "$basis" ]]; then
    cost=$(awk -v w="$basis" -v r="$RATE_EUR_PER_KWH" 'BEGIN { printf "%.2f", w / 1000 * 24 * r }')
    cost_line=$(printf '\n≈ €%s / day  @ €%s/kWh' "$cost" "$RATE_EUR_PER_KWH")
fi

tooltip=$(printf 'Battery\t%s%%  (%s)%s%s' "${cap:-–}" "$status" "$body" "$cost_line")

# class mirrors the built-in module's states, for optional CSS styling.
class="normal"
[[ "$status" == "Charging" || "$status" == "Full" ]] && class="charging"
[[ -n "$cap" ]] && { (( cap <= 15 )) && class="critical" || { (( cap <= 30 )) && class="warning"; }; }

if [[ -n "$cap" ]]; then
    jq -cn --arg tt "$tooltip" --arg cl "$class" --argjson pct "$cap" \
        '{ text: "", tooltip: $tt, class: $cl, percentage: $pct }'
else
    jq -cn --arg tt "$tooltip" --arg cl "$class" \
        '{ text: "AC", tooltip: $tt, class: $cl }'
fi
