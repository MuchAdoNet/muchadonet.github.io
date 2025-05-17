---
sidebar_position: 5
---

# Transactions

To start a database transaction, call `BeginTransactionAsync` on the connector. To commit the transaction, call `CommitTransactionAsync` on the connector, which disposes the transaction after it is committed.

```csharp
await using var connector = CreateConnector();

await using (await connector.BeginTransactionAsync())
{
    await connector.Command("""
        create table widgets (
            id int not null auto_increment primary key,
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
}
```

When the object returned from `BeginTransactionAsync` is disposed, the transaction is disposed, which rolls back the transaction if it has not been committed, e.g. if an exception is thrown.

:::note
ADO.NET requres that the `Transaction` property of [`IDbCommand`](https://docs.microsoft.com/dotnet/api/system.data.idbcommand) be set to the current transaction. MuchAdo takes care of that automatically when creating and executing commands.
:::

`BeginTransactionAsync` has an overload that takes an [`IsolationLevel`](https://learn.microsoft.com/en-us/dotnet/api/system.data.isolationlevel). The default isolation level is provider-specific, but you can also override it via `DbConnectorSettings.DefaultIsolationLevel`.

:::tip
If you are using MuchAdo.Sqlite, there are additional overloads that include the `deferred` parameter for creating [deferred transactions](https://learn.microsoft.com/en-us/dotnet/standard/data/sqlite/transactions#deferred-transactions).
:::

You can explicitly roll back the current transaction with `RollbackTransactionAsync`, but that's not typically necessary, since an uncommitted transaction will be rolled back when it is disposed.

You can attach an existing `IDbTransaction` to the connector by calling `AttachTransaction`.

If you need to access the `IDbTransaction` that is wrapped by the connector, use the `Transaction` property.

:::tip
You can use the `Transaction` property to [create savepoints](https://learn.microsoft.com/en-us/dotnet/api/system.data.common.dbtransaction.save). If you would like MuchAdo to support savepoints directly, please [create an issue](https://github.com/MuchAdoNet/MuchAdo/issues)!
:::
