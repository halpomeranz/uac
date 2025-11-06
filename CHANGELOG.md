# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

- Introduced the `statf` tool, which leverages the `stat` system call to produce file status information in body file format for FreeBSD-based systems tlacking the `stat` and `perl` tools.

### Artifacts

- `live_response/network/ss.yaml`: Updated to show PACKET sockets, socket classic BPF filters, and show the process name and PID of the program to which socket belongs [linux]. (by [ekt0-syn](https://github.com/ekt0-syn))

### Fixed
