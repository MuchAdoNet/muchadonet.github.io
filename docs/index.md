---
sidebar_position: 1
---

# Introduction

The **MuchAdo** class library provides an intuitive API for [working with relational databases](./databases.md) like MySQL, PostgreSQL, SQLite, and Microsoft SQL Server. It is similar to Dapper and other micro ORMs for .NET.

```csharp
var shortWidgets = await connector
    .CommandFormat(
        $"select id, name from widgets where height <= {maxHeight}")
    .QueryAsync<(long Id, string Name)>(cancellationToken);
```

## Key Features

* open and close [database connections](./connections.md) automatically
* use a fluent API to [execute commands](./commands.md) and read data
* read multiple result sets from [command batches](./command-batches.md)
* track the [current transaction](./transactions.md) for correct command execution
* [map data records](./data-mapping.md) into simple types, tuples, and DTOs
* use formatted strings to inject [command parameters](./parameters.md)
* use SQL fragments to [build complex SQL statements](./building-sql.md)
* read database records all at once or one at a time
* call synchronous methods or asynchronous methods with cancellation
* execute stored procedures with parameters
* prepare and/or cache database commands for better performance
