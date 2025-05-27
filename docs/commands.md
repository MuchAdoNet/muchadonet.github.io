---
sidebar_position: 4
---

# Commands

To execute a SQL statement, call `Command` on the connector with the SQL you want to execute, chained with a call to `ExecuteAsync` to execute that SQL. `ExecuteAsync` returns the number of rows affected.

```csharp
await connector
    .Command("""
        create table widgets (
            id bigint not null auto_increment primary key,
            name text not null,
            height real)
        """)
    .ExecuteAsync();
```

## Reading records

If the SQL statement returns data records, call `QueryAsync<T>`, which maps each record to the specified type and returns an [`IReadOnlyList<T>`](https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.ireadonlylist-1).

If the record has a single field, set `T` according to the type of that field value.

```csharp
var widgetNames = await connector
    .Command("select name from widgets")
    .QueryAsync<string>();
```

If the record has multiple fields, you can read them by position into the items of a tuple. The tuple names do not affect data mapping, so be sure the tuple fields are in the right order.

```csharp
var widgetTuples = await connector
    .Command("select id, name from widgets")
    .QueryAsync<(long Id, string Name)>();
```

You can also read record fields by name into the properties of a DTO.

```csharp
sealed record Widget(long Id, string Name, double? Height);
...
var widgets = await connector
    .Command("select id, name, height from widgets")
    .QueryAsync<Widget>();
```

There are many other ways to map records to types. For more details, see [Data Mapping](./data-mapping.md).

### Single records

If the SQL statement always returns a single record, you can call `QuerySingleAsync<T>`, which returns an object of type `T` for that record, but throws an exception if the query returns no records or multiple records.

```csharp
var widgetCount = await connector
    .Command("select count(*) from widgets")
    .QuerySingleAsync<long>();
```

If you would rather ignore any additional records after the first, call `QueryFirstAsync<T>` instead.

If you don't want to throw an exception when there are no records, call `QuerySingleOrDefaultAsync<T>` or `QueryFirstOrDefaultAsync<T>`, which return `default(T)` when the query returns no data records.

### Lazy reading

Reading all of the records at once is usually best for performance, but if you would rather read the records one at a time, use `await foreach` with `EnumerateAsync<T>`.

```csharp
var widgetsById = new Dictionary<long, Widget>();
await foreach (var widget in connector
    .Command("select id, name, height from widgets")
    .EnumerateAsync<Widget>())
{
    widgetsById[widget.Id] = widget;
}
```

:::tip
If you break out of the loop before all records have been read, the remainder of the data may still be read under the hood. It is best to avoid this situation by only querying for data that you need, but if you want to automatically cancel the command when all of the records haven't been read, set the `CancelUnfinishedCommands` connector setting.
:::

## Using parameters

The simplest way to specify command parameters is to call `CommandFormat` instead of `Command`, which uses [formatted SQL](./formatted-sql.md) to provide the parameter values in the SQL statement.

```csharp
var widgetIds = await connector
    .CommandFormat($"select id from widgets where name = {name}")
    .QueryAsync<long>();
```

This may look like a possible SQL injection vulnerability, but it is not, since the injected value is replaced with a parameter placeholder in the SQL statement, and the value itself is passed to the command via parameter. The exact syntax of the parameter placeholder depends on the database provider; by default, it uses arbitrarily named parameters like `@ado1` and `@ado2`, but some providers use `$1` and `$2` or even just `?`.

There is much more to learn about [formatted SQL](./formatted-sql.md) and [parameters](./parameters.md) elsewhere in the documentation.

## Setting the timeout

To set the command timeout, which overrides the default command timeout, chain a call to `WithTimeout` before executing the command.

`WithTimeout` accepts a [`TimeSpan`](https://learn.microsoft.com/en-us/dotnet/api/system.timespan), which is rounded up to the nearest second when used to set the actual [`CommandTimeout`](https://learn.microsoft.com/en-us/dotnet/api/system.data.idbcommand.commandtimeout). You can use `Timeout.InfiniteTimeSpan` or `TimeSpan.Zero` to wait indefinitely.

```csharp
var averageHeight = await connector
    .Command("select avg(height) from widgets")
    .WithTimeout(TimeSpan.FromSeconds(5))
    .QuerySingleAsync<double?>();
```

Most ADO.NET providers have their own mechanism for specifying the default command timeout, but you can also override it for MuchAdo with the `DefaultTimeout` connector setting.

## Stored procedures

MuchAdo also supports stored procedures. Simply call `StoredProcedure` instead of `Command` and pass the name of the stored procedure instead of a SQL query, followed by any [parameters](./parameters.md).

```csharp
await connector
    .StoredProcedure("create_widget",
        Sql.NamedParam("widget_name", name),
        Sql.NamedParam("widget_height", height))
    .ExecuteAsync();
```
