# XUber

A reference design of a ride sharing application (eg Uber, Lyft, etc)

## Overview

Ride sharing apps are uniquely suited to Elixir/Erlang because the are:

- **Asynchronous**: examples of async operations are passenger requesting a ride, drivers notifying the server of their locations, broadcasting a driver's coordinates to mutiple passengers.
- **Parallel**: Millions of peers can be connected simultaneously (theoretically, not yet benchmarked).
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

## Actual log data

```
Passenger `mary` has joined at coordinates {10, 10}
Driver `tom` has joined at coordinates {10, 10}
Driver `tom` has indicated they are available
Passenger `mary` is searching for drivers within 5km of coordinates {10, 10}
Passenger `mary` found drivers: `tom` @distance=0.0km
Passenger `mary` is searching for drivers within 5km of coordinates {10, 10}
Passenger `mary` found drivers: `tom` @distance=0.0km
Passenger `mary` is searching for drivers within 5km of coordinates {10, 10}
Passenger `mary` found drivers: `tom` @distance=0.0km
Passenger `mary` has requested a pickup at coordinates {10, 10}
Dispatcher received request for pickup at {10, 10} for `mary`
Dispatcher assigned driver `tom` to pickup `mary`
Driver `tom` has been notified to pickup passenger `mary`, pickup #PID<0.878.0>
Passenger `mary` has been notified that driver `tom` will pick them up, pickup #PID<0.878.0>
Driver `tom` has moved to coordinates {10, 15}
Driver `tom` has moved to coordinates {10, 16}
Driver `tom` has arrived at destination {10, 16}
Ride #PID<0.879.0> has started for passenger `mary` and driver `tom`
Driver `tom` has departed, ride #PID<0.879.0>
Passenger `mary` has been picked up and is departing with ride #PID<0.879.0>
Ride #PID<0.879.0> is at {10, 16}
Driver `tom` has moved to coordinates {10, 16}
Ride #PID<0.879.0> is at {10, 16}
Passenger `mary` has moved to coordinates {10, 16}
Driver `tom` has moved to coordinates {10, 17}
Ride #PID<0.879.0> is at {10, 17}
Passenger `mary` has moved to coordinates {10, 17}
Ride #PID<0.879.0> is at {10, 17}
Ride #PID<0.879.0> is at {10, 18}
Driver `tom` has moved to coordinates {10, 18}
Passenger `mary` has moved to coordinates {10, 18}
Ride #PID<0.879.0> is at {10, 18}
Passenger `mary` has arrived at destination {10, 18}
Driver `tom` has dropped off passenger `mary` at coordinates {10, 18}
Ride #PID<0.879.0> has been completed. Dropoff location was {10, 18}
Passenger `mary` has gone offline
Driver `tom` has indicated they are unavailable
Driver `tom` has gone offline
```
