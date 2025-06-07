---
sidebar_position: 1
---

# Introduction

The **MuchAdo** class library provides an intuitive API for [working with relational databases](./databases.md) like MySQL, PostgreSQL, SQLite, and Microsoft SQL Server. It is [similar to Dapper](./other-libraries.md) and other micro ORMs for .NET.

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
* use [formatted SQL](./formatted-sql.md) to build SQL statements
* use [parameters](./parameters.md) with commands and stored procedures
* [improve performance](./optimizations.md) by preparing, caching, and pooling
* provide [analyzers](./analyzers.md) to help ensure proper use of the library
