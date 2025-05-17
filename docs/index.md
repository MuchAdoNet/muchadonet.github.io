---
sidebar_position: 1
---

# Getting Started

The **MuchAdo** class library provides an intuitive API for working with ADO.NET providers for relational databases like [MySQL](https://mysqlconnector.net/), [PostgreSQL](https://www.npgsql.org/), [SQLite](https://learn.microsoft.com/en-us/dotnet/standard/data/sqlite/), and [Microsoft SQL Server](https://learn.microsoft.com/en-us/sql/connect/ado-net/introduction-microsoft-data-sqlclient-namespace). It is similar to [Dapper](https://github.com/DapperLib/Dapper) and other micro ORMs for .NET.

## Key Features

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
* generate SQL and parameters optimized for each database provider

## Databases

MuchAdo works with any ADO.NET database provider, but if you are using a database provider with its own MuchAdo package, you can use it to get better default settings for that database. Each provider-specific package has its own connector class that derives from `DbConnector`.

### MySql

Use [MuchAdo.MySql](https://www.nuget.org/packages/MuchAdo.MySql) with [MySqlConnector](https://mysqlconnector.net/), the recommended provider for [MySQL](https://www.mysql.com/).

### PostgreSQL

Use [MuchAdo.Npgsql](https://www.nuget.org/packages/MuchAdo.Npgsql) with [Npgsql](https://www.npgsql.org/), the recommended provider for [PostgreSQL](https://www.postgresql.org/).

### SQLite

Use [MuchAdo.Sqlite](https://www.nuget.org/packages/MuchAdo.Sqlite) with [Microsoft.Data.Sqlite](https://learn.microsoft.com/en-us/dotnet/standard/data/sqlite/), the recommneded provider for [SQLite](https://www.sqlite.org/).

### Microsoft SQL Server

Use the standard [MuchAdo](https://www.nuget.org/packages/MuchAdo) NuGet package with [Microsoft.Data.SqlClient](https://learn.microsoft.com/en-us/sql/connect/ado-net/introduction-microsoft-data-sqlclient-namespace) or the older [System.Data.SqlClient](https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient). Please [create an issue](https://github.com/MuchAdoNet/MuchAdo/issues) if you think SQL Server should have its own provider-specific package!

### Other databases

Again, MuchAdo works with any ADO.NET database provider, but [let us know](https://github.com/MuchAdoNet/MuchAdo/issues) if your favorite provider doesn't work or should have its own provider-specific package.
