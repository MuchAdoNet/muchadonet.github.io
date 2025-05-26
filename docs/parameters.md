---
sidebar_position: 9
---

# Parameters

Parameters are usually used with [formatted SQL](./formatted-sql.md), which adds both the parameter and its placeholder.

If you are calling a stored procedure that requires parameters, you can use the same methods that are documented in [formatted SQL](./formatted-sql.md), but include the parameter sources as arguments after the stored procedure name.

You can do the same if you are executing a command but adding the parameter placeholders yourself.

## SqlParamSource

As already documented, classes that represent one or more parameters are derived from `SqlParamSource`.

To filter out parameters by name, use `Where`.

To transform the names of the parameters, use `Renamed`.
