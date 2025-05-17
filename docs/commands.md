---
sidebar_position: 3
---

# Commands

To execute a SQL statement, call `Command` on the connector with the SQL you want to execute, chained with a call to `ExecuteAsync` to execute that SQL. `ExecuteAsync` returns the number of rows affected (or whatever `ExecuteNonQuery` returns for your provider).

## Data Records

If the SQL statement returns data records, call `QueryAsync<T>`, which maps each data record to the specified type and returns an `IReadOnlyList<T>`.

If the data record has a single field, set T to the type of that field value.

If the data record has multiple fields, you can read them by position into the items of a tuple or by name into the properties of a DTO.

For more details on how data records are read, see Data Mapping.

If the SQL statement always returns a single data record, you can call `QuerySingleAsync<T>`, which returns an object of type `T` for data that record, but throws an exception if the query returns no data records or multiple data records.

If you would rather ignore any additional data records after the first, call `QueryFirstAsync<T>` instead.

If you don't want to throw an exception when there are no data records, call `QuerySingleOrDefaultAsync<T>` or `QueryFirstOrDefaultAsync<T>`, which return `default(T)` when there are no data records to read.

Reading all of the data records at once is usually best for performance, but if you would rather read the data records one at a time, use await foreach with `EnumerateAsync<T>`.

## Parameters

The best way to specify parameters in a SQL statement is to use formatted SQL, which is discussed in detail under SQL Building.

The simplest way to specify parameters in formatted SQL is to call `CommandFormat` instead of `Command` and use string interpolation to provide the parameter values in the SQL statement.

This may look like a SQL injection vulnerability, but it is not, since each value is replaced with a parameter placeholder, and the value itself is passed to the command via parameter. The exact syntax of the parameter placeholder depends on the database provider; by default, it uses arbitrarily named parameters like `@ado1` and `@ado2`, but some providers use `$1` and `$2` or even just `?`.

For other ways to specify parameters, see Parameters.

## Timeout

To set the command timeout, which overrides the default command timeout, chain a call to `WithTimeout` immediately before executing the command.

`WithTimeout` accepts a `TimeSpan`, which is rounded up to the nearest second when used to set `IDbCommand.CommandTimeout`. You can use `Timeout.InfiniteTimeSpan` or `TimeSpan.Zero` to wait indefinitely.

Most ADO.NET providers have a mechanism for specifying the default command timeout, but you can also override it with `DbConnectorSettings.DefaultTimeout`.

## Stored Procedures

To execute a stored procedure, call `StoredProcedure` instead of `Command` and pass the name of the stored procedure instead of a SQL statement.
