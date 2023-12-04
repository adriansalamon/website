%{
    name: "Creek",
    description: "A PostgreSQL system for Change Data Capture.",
    link: %{
        label: "github.com",
        href: "https://github.com/modfin/creek"
    },
    tags: ~w()
}
---

Creek is a PostgreSQL Change-Data-Capture (CDC) based system for event sourcing.
I developed it as part of my summer internship at [Modular Finance](https://en.modularfinance.se/), and it is
[open source](https://github.com/modfin/creek). The system works by listening to
changes in a Postgres Write Ahead Log, and then publishing these changes over a
message queue (NATS in this case). The system also has a [PostgreSQL consumer](https://github.com/modfin/creek-pg-client),
 which can be used to apply
the changes to another database to keep it in sync with the source database. The
main use case for this is to keep PostgreSQL databases in sync, but it can also
be used to stream data changes to other systems. One example is to stream stock
market price data over websockets for realtime stock prices on a website.

The system is written in Go, and includes nice features such as snapshotting, a
simple RPC API, a CLI tool to monitor the system, and a Go library that makes it
simple to interact with.

