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

* generate SQL and parameters optimized for each [database provider](./databases.md)
* open and close [database connections](./connections.md) automatically
* use formatted strings to safely inject parameters and build complex SQL statements
* map SELECT statements into simple types, tuples, and DTOs
* track the [current transaction](./transactions.md) for correct command execution
* expand collections for IN clauses and bulk INSERT
* read database records all at once or one at a time
* call synchronous methods or asynchronous methods with cancellation
* read multiple result sets from multi-statement commands or batches
* execute stored procedures with parameters
* prepare and/or cache database commands for better performance
