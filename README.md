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

## Example log data

```
Passenger `mary` has joined at coordinates {10, 10}
Driver `tom` has joined at coordinates {10, 10}
Driver `tom` has indicated they are available
Passenger `mary` is searching for drivers within 5km of coordinates {10, 10}
Passenger `mary` found drivers: [{#PID<0.874.0>, {10, 10}, 0.0}]
Passenger `mary` is searching for drivers within 5km of coordinates {10, 10}
Passenger `mary` found drivers: [{#PID<0.874.0>, {10, 10}, 0.0}]
Passenger `mary` is searching for drivers within 5km of coordinates {10, 10}
Passenger `mary` found drivers: [{#PID<0.874.0>, {10, 10}, 0.0}]
Passenger `mary` has requested a pickup at coordinates {10, 10}
Dispatcher received request for pickup at {10, 10} for #PID<0.872.0>
Dispatcher assigned driver #PID<0.874.0> to pickup #PID<0.872.0>
Driver `tom` has been notified to pickup passenger #PID<0.872.0>, pickup #PID<0.876.0>
Passenger `mary` has been notified that driver #PID<0.874.0> will pick them up, pickup #PID<0.876.0>
Driver `tom` has moved to coordinates {10, 15}
Driver `tom` has moved to coordinates {10, 16}
Driver `tom` has arrived at destination {10, 16}
Passenger `mary` has been picked up and is departing with ride #PID<0.877.0>
Driver `tom` has departed, ride #PID<0.877.0>
Driver `tom` has moved to coordinates {10, 16}
Ride #PID<0.877.0> is at {10, 16}
Passenger `mary` has moved to coordinates {10, 16}
Ride #PID<0.877.0> is at {10, 16}
Driver `tom` has moved to coordinates {10, 17}
Ride #PID<0.877.0> is at {10, 17}
Passenger `mary` has moved to coordinates {10, 17}
Driver `tom` has moved to coordinates {10, 18}
Ride #PID<0.877.0> is at {10, 17}
Passenger `mary` has moved to coordinates {10, 18}
Ride #PID<0.877.0> is at {10, 18}
Passenger `mary` has arrived at destination {10, 18}
Ride #PID<0.877.0> is at {10, 18}
Driver `tom` has dropped off passenger #PID<0.872.0> at coordinates {10, 18}
Ride #PID<0.877.0> has been completed. Dropoff location was {10, 18}
Driver `tom` has indicated they are unavailable
Driver `tom` has gone offline
Passenger `mary` has gone offline
```
