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

To use MuchAdo, add a reference to the [NuGet package](./databases.md) that corresponds to your database. Strongly consider adding a reference to [MuchAdo.Analyzers](./analyzers.md) as well.

## Key Features

* open and close [database connections](./connections.md) automatically
* use a fluent API to [execute commands](./commands.md) and read data
* read multiple result sets from [command batches](./command-batches.md)
* leverage [transactions](./transactions.md) simply and correctly
* [map data records](./data-mapping.md) into simple types, tuples, and DTOs
* use [formatted SQL](./formatted-sql.md) to build SQL statements
* specify [parameters](./parameters.md) for commands and stored procedures
* support [resilience](./resilience.md) by retrying transient failures
* [improve performance](./optimizations.md) by preparing, caching, and pooling
* provide [analyzers](./analyzers.md) to help ensure proper use of the library
