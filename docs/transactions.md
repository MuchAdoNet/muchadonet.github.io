---
sidebar_position: 5
---

# Transactions

To start a database transaction, call `BeginTransactionAsync` on the connector. To commit the transaction, call `CommitTransactionAsync` on the connector, which disposes the transaction after it is committed.

```csharp
await using var connector = CreateConnector();

await connector.BeginTransactionAsync();

await connector.Command("""
    create table widgets (
        id integer primary key autoincrement,
        name text not null,
        height real not null);
    """).ExecuteAsync();

await connector.Command("""
    insert into widgets (name, height)
        values ('First', 6.875);
    insert into widgets (name, height)
        values ('Second', 3.1415);
    """).ExecuteAsync();

await connector.CommitTransactionAsync();
```

:::note
ADO.NET requres that the `Transaction` property of [`IDbCommand`](https://docs.microsoft.com/dotnet/api/system.data.idbcommand) be set to the current transaction. `DbConnector` takes care of that automatically when creating and executing commands.
:::

You can optionally dispose the object returned from `BeginTransactionAsync` to dispose the transaction, which rolls back the transaction if it has not already been committed. The transaction will also be disposed when the connector is disposed, so the returned object can usually be ignored.

You can explicitly roll back the current transaction with `RollbackTransactionAsync`, but that's not typically necessary, since an uncommitted transaction will be rolled back when it is disposed.

You can attach an existing `IDbTransaction` to the connector by calling `AttachTransaction`.

If you need to access the `IDbTransaction` that is wrapped by the connector, use the `Transaction` property.
