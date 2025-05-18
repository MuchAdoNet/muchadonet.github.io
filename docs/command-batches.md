---
sidebar_position: 5
---

# Command Batches

To execute multiple SQL statements in one database call, which can improve performance for databases with significant latency, chain multiple calls to `Command` (and/or `StoredProcedure`). This uses your ADO.NET provider's support for `DbBatch` to efficiently execute multiple commands with their own parameters.

If your provider does not support `DbBatch`, you may be able to execute multiple statements in a single command by separating the SQL statements with semicolons.

If only one of the SQL statements returns data records, or if all of the statements return the same kind of data record, you can use `QueryAsync<T>`.
If each statement returns a different kind of data record, you can enumerate the result sets by using await foreach with `QueryMultipleAsync`. To read the data records of each result set, call `ReadAsync<T>` or `EnumerateAsync<T>` on the result set.

:::tip
Batching commands with embedded databases like SQLite may actually hurt performance, since there is so little latency. Consider executing each command separately instead.
:::

Note that any timeout specified by `WithTimeout` applies to the entire command batch, not an individual command.
