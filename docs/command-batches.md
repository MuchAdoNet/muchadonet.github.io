---
sidebar_position: 5
---

# Command Batches

To execute multiple SQL statements in one database call, which can improve performance for databases with significant latency, chain multiple calls to `Command` and/or `CommandFormat`. MuchAdo uses ADO.NET provider support for [`DbBatch`](https://learn.microsoft.com/en-us/dotnet/api/system.data.common.dbbatch) to efficiently execute multiple commands.

```csharp
var newWidgetId = connector
    .CommandFormat(
        $"insert into widgets (name, height) values ({name}, {height})")
    .Command("select last_insert_id()")
    .QuerySingle<long>();
```

If your provider does not support `DbBatch`, you may be able to execute multiple statements in a single command by separating the SQL statements with semicolons.

```csharp
var nextWidgetId = connector
    .CommandFormat($"""
        insert into widgets (name, height) values ({name}, {height});
        select last_insert_id();
        """)
    .QuerySingle<long>();
```

:::tip
Batching commands with embedded databases like SQLite may actually hurt performance. Consider executing each command separately instead.
:::

Note that any timeout specified by `WithTimeout` applies to the entire command batch, not an individual command.

## Reading result sets

If only one of the SQL statements returns data records, or if all of the statements return the same kind of record, you can read the data as usual with one of the `Query` or `Enumerate` methods.

If each statement returns a different kind of data record, call `QueryMultipleAsync` to get a disposable result set reader. For each statement that returns records, call one of the `Read` or `Enumerate` methods.

```csharp
await using (var reader = await connector
    .Command("select name from widgets where height < 5")
    .Command("select id from widgets where height >= 5")
    .QueryMultipleAsync())
{
    shortWidgetNames.AddRange(await reader.ReadAsync<string>());
    longWidgetIds.AddRange(await reader.ReadAsync<long>());
}
```

## ADO.NET access

While a command batch is being executed, the `ActiveBatch` property of the connector will be set to the corresponding `DbBatch`.
