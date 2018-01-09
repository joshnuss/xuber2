# XUber

A reference design of a ride sharing application (eg Uber, Lyft, etc)

## Overview

Ride sharing apps are uniquely suited to Elixir/Erlang because:

- **Highly asynchronous**: passengers requesting rides, drivers notifying the server of their locations, broadcasting drivers coordinates, all are asynchronous operation.
- **Massively parallel**: Millions of peers can be connected simultaneously (theoretically, not yet benchmarked)
- **Soft-realtime**: Comms between peers happen in near realtime (subsecond)
- **Full-duplex**: Phoenix supports full-duplex WebSockets
- **Fault tolerance**: Failures do no propagate. For example a exception in a specific ride cannot effect another, same goes for a node, tile and data center.
- **Resiliency**: Failures can have backup plans. For example, if a driver is not responding to a pickup request, a different driver can be dispatched.
- **Multi DC**: The management of drivers and passengers is sharded grographically (like cell phone network), so different parts of the "grid" can run in different data centers.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xuber` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xuber, "~> 0.1.0"}
  ]
end
```
