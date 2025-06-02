---
sidebar_position: 9
---

# Parameters

Parameters are usually used with [formatted SQL](./formatted-sql.md), which adds both the parameter and its placeholder.

This may look like a possible SQL injection vulnerability, but it is not, since the injected value is replaced with a parameter placeholder in the SQL statement, and the value itself is passed to the command via parameter. The exact syntax of the parameter placeholder depends on the database provider; by default, it uses arbitrarily named parameters like `@ado1` and `@ado2`, but some providers use `$1` and `$2` or even just `?`.

Using this technique with a collection will create one parameter whose value is the collection. If you want to expand a non-empty collection into a parenthesized set of parameters for use with the `IN` keyword, use the `set` format specifier.

```csharp
var widgetsFromIds = await connector
    .CommandFormat($"""
        select id, name, height from widgets
        where id in {widgetIds:set}
        """)
    .QueryAsync<Widget>();
```

If you are calling a stored procedure that requires parameters, you can use the same methods that are documented in [formatted SQL](./formatted-sql.md), but include the parameter sources as arguments after the stored procedure name.

You can do the same if you are executing a command but adding the parameter placeholders yourself.

## SqlParamSource

As already documented, classes that represent one or more parameters are derived from `SqlParamSource`.

A `SqlParamSource` represents a list of parameters. It derives from `SqlSource`, and when one used as a SQL fragment, it generates parameter placeholders for parameters with the corresponding values, comma-separated in the SQL if there are more than one. See [Parameters](./parameters.md) for more information about `SqlParamSource`.

`Sql.Param` creates an unnamed parameter with the specified value. The returned object has a `Value` property that can be set, if you want to reuse the object for multiple commands to save the allocation.

:::info
Depending on the database, unnamed parameters use named placeholders like `@ado1`, numbered placeholders like `$1`, or positional placeholders like `?`.
:::

`Sql.RepeatParam` creates an unnamed parameter designed to be used more than once in a single command. For databases that use named or numbered placeholders, the same placeholder is used each time the same object from `Sql.RepeatParam` is used, which could be more efficient, depending on your database.

`Sql.Params` generates unnamed parameters from a collection. The collection is not copied; parameters will be generated from the items just in time. If the collection is empty, empty SQL will be produced, which could result in invalid SQL. Generally, you should check for an empty collection and bypass the command or add a conditional to generate valid SQL for that case.

## Named Parameters

Unnamed parameters are usually simpler and sometimes more efficient, but you can also create named parameters. Be sure to avoid specifying two different parameters with the same name.

`Sql.NamedParam` creates a parameter with the specified name and value. Named parameters use the corresponding named placeholder, e.g. `@height`.

`Sql.NamedParams` creates multiple parameters with the specified names and values, either from a collection of tuple pairs where the first value is the parameter name, or from a collection of key/value pairs where the key is the parameter name. As with `Sql.Params`, you should usually avoid empty collections.

## DTOs

`Sql.DtoColumnNames` is useful when selecting fields to map to a DTO.

Use `From` when you're using an explicit table name or alias.

`Sql.DtoParams` generates unnamed parameters for the value of each property of a DTO. It is often used with `Sql.DtoColumnNames` when inserting database records.

In both cases, you can use `Where` to filter properties by name.

If you prefer named parameters, you can use `Sql.DtoNamedParams`.

To add a prefix or suffix to help ensure that the parameter name is unique, use `Renamed`.

If you want to manually generate parameter placeholders for a DTO, use `Sql.DtoParamNames`.

To filter out parameters by name, use `Where`.

To transform the names of the parameters, use `Renamed`.
