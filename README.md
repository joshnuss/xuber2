# XUber

A reference design of a ride sharing application (eg Uber, Lyft, etc)

## Overview

Ride sharing apps are uniquely suited to Elixir/Erlang because the are:

- **Highly asynchronous**: examples of async operations are passenger requesting a ride, drivers notifying the server of their locations, broadcasting a driver's coordinates to mutiple passengers.
- **Massively parallel**: Millions of peers can be connected simultaneously (theoretically, not yet benchmarked).
- **Soft-realtime**: Communication between drivers & passengers occur in near realtime (subsecond).
- **Full-duplex**: Phoenix supports full-duplex WebSockets between mobile device and cloud.
- **Fault tolerance**: Failures do no propagate. For example a exception in a specific ride cannot effect another, same goes for a node, tile and data center.
- **Resiliency**: Failures can have backup plans. For example, if a driver is not responding to a pickup request, a different driver can be dispatched.
- **Multi DC**: The management of drivers and passengers is sharded geographically (like a cell phone network). If failure occurs in a specific geographic region, other regions are unaffected.

## Installation

```bash
hub clone joshnuss/xuber2
```

## Running examples

```
mix run --no-halt examples/basic.exs
```
