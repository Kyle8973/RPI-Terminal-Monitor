
# Raspberry Pi Terminal System Monitor

A lightweight **real-time terminal monitoring dashboard for Raspberry Pi** written in Bash.

This script provides a live system overview directly in the terminal, including **CPU load, temperature, network throughput, memory usage, Docker containers, and hardware throttling status**. It also includes **interactive fan control** and automatic cleanup on exit.

Designed for **headless Raspberry Pi servers**, home labs, and infrastructure monitoring where minimal overhead is important.

----------

## Features:

### System Overview

-   CPU load monitoring
-   Memory usage
-   Disk usage
-   System uptime
-   Local IP address

### Hardware Health:

-   CPU temperature
-   Voltage monitoring
-   CPU clock speed (GHz)
-   Hardware throttling detection

### Network Monitoring:

-   Automatic active interface detection
-   Real-time upload / download speeds

### Docker Awareness:

-   Displays number of running containers

### Cooling Control:

-   Automatic fan state detection
-   Manual fan override with keyboard toggle
-   Safety reset to **Auto mode on exit**

### Terminal Interface:

-   Clean real-time dashboard
-   Color-coded system health indicators
-   Cursor-safe exit handling
-   Updates every second

----------

## Example Output:
```
================= KYLE'S PI MONITOR ==================  
  
 Local IP    : 192.168.1.45  
 Uptime      : 2 hours, 14 minutes  
 Temperature : 47.8'C  
 Fan Status  : AUTO OFF  
  
------------------------------------------------------  
  
 CPU Load    : 5.4%  
 Memory      : 512MB / 2048MB  
 Disk Space  : 18G / 64G (30%)  
 Network     : ↓ 220 KB/s  ↑ 34 KB/s  
 Docker      : 3 Containers Running  
  
------------------------------------------------------  
  
 CPU Clock   : 1.5 GHz  
 Voltage     : 0.85V  
 Throttled   : NO  
  
======================================================  
  
 [F] Toggle Manual Fan | [Ctrl+C] Stop & Reset Fan  
 Updated: 14:52:12
```
----------

## Requirements:

-   Raspberry Pi (tested on Pi 4)
-   Raspberry Pi OS / Debian based system
-   Bash
-   `vcgencmd` installed (included with Raspberry Pi firmware)
-   `docker` (optional, for container monitoring)

Required system paths:

- /sys/class/net/  
- /sys/class/thermal/  
- /sys/devices/system/cpu/

----------

## Installation:

Clone the repository:

`git clone https://github.com/Kyle8973/rpi-terminal-monitor.git `
`cd pi-terminal-monitor`

Make the script executable:

`chmod  +x monitor.sh`

Run the monitor:

`./monitor.sh`

----------

## Controls
| Key |Action  |
|--|--|
|  F| Toggle manual fan control |
|  Ctrl + C| Exit monitor and restore fan auto mode |

----------
Kyle8973
