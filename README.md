# Configurable UART Design

A configurable UART (Universal Asynchronous Receiver/Transmitter) module implemented in SystemVerilog with support for multiple data widths, baud rates, and parity configurations.

## Overview

This UART design provides both transmitter (TX) and receiver (RX) functionality with configurable parameters to support various communication requirements. The design operates on a 576 kHz system clock and uses a baud rate generator to create appropriate timing for different UART speeds.

## Key Features

- **Configurable Data Width**: Supports 8, 16, 24, and 32-bit data transmission
- **Multiple Baud Rates**: 9600, 19200, 38400, and 57600 bps
- **Parity Support**: Optional parity-per-byte functionality
- **Handshaking Protocol**: Valid-ready protocol for reliable data transfer
- **Error Detection**: Built-in error detection and reporting

## Module Structure

- **`uart_top.sv`**: Top-level module integrating TX, RX, and baud rate generator
- **`brg.sv`**: Baud Rate Generator for timing control
- **`tx_asm.sv`**: UART Transmitter with ASM-based state machine
- **`rx_asm.sv`**: UART Receiver with ASM-based state machine

