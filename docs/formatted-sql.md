---
sidebar_position: 8
---

# Formatted SQL

Formatted SQL uses string interpolation to build SQL statements from SQL fragments and parameter values.

Formatted SQL is most commonly used when calling the `CommandFormat` method on a connector, passing an interpolated string with parameter values. `CommandFormat` is actually a convenience method that is equivalent to calling `Sql.Format` and passing the returned `SqlSource` to the `Command` method.

```csharp
SqlSource sql = Sql.Format($"select id from widgets where name = {name}");
long widgetId = await connector.Command(sql).QuerySingleAsync<long>();
```

A `SqlSource` represents a SQL fragment and any attached parameter values. The `Sql` static class contains many methods that create SqlSource objects.

## SQL Text

`Sql.Format` is the most useful method for building SQL fragments. An unnamed parameter is substituted for each interpolated expression, unless the expression is a `SqlSource`, in which case the corresponding SQL fragment is substituted.

`Sql.Raw` creates a SQL fragment from a raw SQL string.

`Sql.Empty` contains an empty SQL fragment, equivalent to `Sql.Raw("")`.

`Sql.Name` surrounds the specified string with delimiters that prevent it from being interpreted as a SQL keyword. ANSI SQL uses double quotes for this, but some databases have their own syntax, so be sure to use the right MuchAdo package or `SqlSyntax`.

```csharp
var sql = Sql.Format($"""
    select id from {Sql.Name(tableName)}
    where id {Sql.Raw(reverse ? "<" : ">")} {id}
    order by id {(reverse ? Sql.Raw("desc") : Sql.Empty)}
    limit 1
    """);
return await connector.Command(sql).QuerySingleOrDefaultAsync<long?>();
```

## SQL Building

`SqlSource` instances can be concatenated with the `+` operator or with `Sql.Concat`.

`Sql.Intersperse` works like `string.Join`; it intersperses SQL fragments with the specified raw SQL separator. Empty fragments are ignored, rather than doubling up the separator.

`Sql.Clauses` intersperses SQL fragments with newlines, equivalent to `Sql.Intersperse("\n", ...})"`.

`Sql.List` intersperses SQL fragments with commas, equivalent to `Sql.Intersperse(", ", ...})"`.

`Sql.Tuple` is shorthand for a comma-separated list surrounded by parentheses, equivalent to `Sql.Format($"({Sql.List(...)})"`.

`Sql.Set` is like `Sql.Tuple`, but it throws an exception when the list is empty, since `in ()` is not valid SQL.

```csharp
await connector
    .CommandFormat($"""
        insert into widgets (name, height)
        values {Sql.List(widgets.Select(x =>
            Sql.Tuple(Sql.Param(x.Name), Sql.Param(x.Height))))}
        """)
    .ExecuteAsync();
```

## SQL Keywords

There are a few methods that generate SQL keywords. The advantage of these methods over typing the keyword directly into formatted SQL is that the keyword is omitted if the arguments are missing or all empty.

`Sql.And` and `Sql.Or` intersperse non-empty arguments with `AND` or `OR` keywords. Each argument is surrounded with parentheses. If there is only one non-empty argument, it is used as-is.

`Sql.Where` and `Sql.Having` generate a `WHERE` or `HAVING` keyword followed by the arguments, interspersed with `AND` keywords, as above.

`Sql.OrderBy` and `Sql.GroupBy` generate `ORDER BY` or `GROUP BY` keywords followed by the arguments, interspersed with commas.

```csharp
var conditions = new List<SqlSource>();
if (minHeight.HasValue)
    conditions.Add(Sql.Format($"height >= {minHeight.Value}"));
if (maxHeight.HasValue)
    conditions.Add(Sql.Format($"height <= {maxHeight.Value}"));
return await connector
    .CommandFormat($"select count(*) from widgets {Sql.Where(conditions)}")
    .QuerySingleAsync<int>();
```

## Parameters

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
