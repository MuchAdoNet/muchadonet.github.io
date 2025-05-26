---
sidebar_position: 4
---

# Commands

To execute a SQL statement, call `Command` on the connector with the SQL you want to execute, chained with a call to `ExecuteAsync` to execute that SQL. `ExecuteAsync` returns the number of rows affected (or whatever `ExecuteNonQueryAsync` returns for your provider).

```csharp
await connector
    .Command("""
        create table widgets (
            id bigint not null auto_increment primary key,
            name text not null,
            height real not null)
        """)
    .ExecuteAsync();
```

## Reading data records

If the SQL statement returns data records, call `QueryAsync<T>`, which maps each data record to the specified type and returns an `IReadOnlyList<T>`.

If the data record has a single field, set `T` to the type of that field value.

```csharp
var widgetNames = await connector
    .Command("select name from widgets")
    .QueryAsync<string>();
```

If the data record has multiple fields, you can read them by position into the items of a tuple. The tuple names do not affect data mapping, so be sure the tuple fields are in the right order.

```csharp
var widgetTuples = await connector
    .Command("select id, name from widgets")
    .QueryAsync<(long Id, string Name)>();
```

You can also read data record fields by name into the properties of a DTO.

```csharp
private sealed record Widget(int Id, string Name, double Height);
...
var widgets = await connector
    .Command("select id, name, height from widgets")
    .QueryAsync<Widget>();
```

There are many other ways to map data records to types. For more details, see [Data Mapping](./data-mapping.md).

If the SQL statement always returns a single data record, you can call `QuerySingleAsync<T>`, which returns an object of type `T` for data that record, but throws an exception if the query returns no data records or multiple data records.

```csharp
var widgetCount = await connector
    .Command("select count(*) from widgets")
    .QuerySingleAsync<long>();
```

If you would rather ignore any additional data records after the first, call `QueryFirstAsync<T>` instead.

If you don't want to throw an exception when there are no data records, call `QuerySingleOrDefaultAsync<T>` or `QueryFirstOrDefaultAsync<T>`, which return `default(T)` when the query returns no data records.

Reading all of the data records at once is usually best for performance, but if you would rather read the data records one at a time, use `await foreach` with `EnumerateAsync<T>`.

```csharp
var widgetsById = new Dictionary<int, Widget>();
await foreach (var widget in connector
    .Command("select id, name, height from widgets")
    .EnumerateAsync<Widget>())
{
    widgetsById[widget.Id] = widget;
}
```

## Using parameters

The simplest way to specify command parameters is to call `CommandFormat` instead of `Command`, which uses formatted SQL to provide the parameter values in the SQL statement.

```csharp
var widgetIds = await connector
    .CommandFormat($"select id from widgets where name = {name}")
    .QueryAsync<long>();
```

This may look like a possible SQL injection vulnerability, but it is not, since the injected value is replaced with a parameter placeholder, and the value itself is passed to the command via parameter. The exact syntax of the parameter placeholder depends on the database provider; by default, it uses arbitrarily named parameters like `@ado1` and `@ado2`, but some providers use `$1` and `$2` or even just `?`.

There is much more to learn about [formatted SQL](./formatted-sql.md) and [parameters](./parameters.md) later in the documentation.

## Setting the timeout

To set the command timeout, which overrides the default command timeout, chain a call to `WithTimeout` before executing the command.

`WithTimeout` accepts a `TimeSpan`, which is rounded up to the nearest second when used to set `IDbCommand.CommandTimeout`. You can use `Timeout.InfiniteTimeSpan` or `TimeSpan.Zero` to wait indefinitely.

```csharp
var averageHeight = await connector
    .Command("select avg(height) from widgets")
    .WithTimeout(TimeSpan.FromSeconds(5))
    .QuerySingleAsync<double?>();
```

Most ADO.NET providers have a mechanism for specifying the default command timeout, but you can also override it with the `DefaultTimeout` connector setting.

## Stored procedures

MuchAdo also supports stored procedures. Simply call `StoredProcedure` instead of `Command` and pass the name of the stored procedure instead of a SQL query.

```csharp
connector.StoredProcedure("CreateWidget", ("name", name), ("size", size)).Execute();
```
