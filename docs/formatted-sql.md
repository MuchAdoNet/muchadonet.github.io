---
sidebar_position: 8
---

# Formatted SQL

Formatted SQL uses string interpolation to build SQL statements from SQL fragments and parameter values.

Formatted SQL is most commonly used when calling the `CommandFormat` method on a connector, passing an interpolated string with parameter values. `CommandFormat` is actually a convenience method that is equivalent to calling `Sql.Format` and passing the returned `SqlSource` to the `Command` method.

A `SqlSource` represents a SQL fragment and any attached parameter values. The `Sql` static class contains many methods that create SqlSource objects.

## Text

`Sql.Format` is the most useful method for building SQL fragments. An unnamed parameter is substituted for each interpolated expression, unless the expression is a `SqlSource`, in which case the corresponding SQL fragment is substituted.

`Sql.Raw` creates a SQL fragment from a raw SQL string with no parameter values.

`Sql.Empty` contains an empty SQL fragment, equivalent to `Sql.Raw("")`.

`Sql.Name` surrounds the specified string with delimiters that prevent it from being interpreted as a SQL keyword. ANSI SQL uses double quotes for this, but some databases have their own syntax, so be sure to use the right MuchAdo package or `SqlSyntax`.

## Concatenation

`SqlSource` instances can be concatenated with the `+` operator, but there are usually better ways to build SQL from fragments, as documented below.

As mentioned previously, `Sql.Format` can be used to build a `SqlSource` from other instances.

Like the `+` operator, `Sql.Concat` concatenates any number of SQL fragments.

`Sql.Join` works like `string.Join`; it interleaves SQL fragments with the specified raw SQL separator. Empty fragments are ignored, rather than doubling up the separator.

`Sql.Clauses` is shorthand for calling `Sql.Join` with a newline.

`Sql.List` is shorthand for calling `Sql.Join` with a comma.

`Sql.Tuple` is shorthand for a comma-separated list surrounded by parentheses, equivalent to `Sql.Format($"({Sql.List(...)})"`.

## Keywords

There are a few methods that generate keywords. The advantage of these methods over typing the keyword directly is that the keyword is omitted if the arguments are missing or all empty.

`Sql.Where` and `Sql.Having` generate a `WHERE` or `HAVING` keyword followed by the specified argument.

`Sql.OrderBy` and `Sql.GroupBy` generate `ORDER BY` or `GROUP BY` keywords followed by the arguments separated by commas.

`Sql.And` and `Sql.Or` separate any non-empty arguments with `AND` or `OR` keywords. The entire expression is surrounded with parentheses, in case there is nesting. If there is only one non-empty argument, it is used as-is.

## Parameters

Classes that represent one or more parameters are derived from `SqlParamSource`. When a parameter source is used in formatted SQL, parameter placeholders are generated that reference parameters with the corresponding values, comma-separated if there are more than one. Depending on the database, unnamed parameters use named placeholders like `@ado1`, numbered placeholders like `$1`, or positional placeholders like `?`. See [Parameters](./parameters.md) for more information about `SqlParamSource`.

`Sql.Param` creates an unnamed parameter with the specified value. The returned object has a `Value` property that can be set, if you want to reuse the object for multiple commands to save the allocation.

`Sql.RepeatParam` creates an unnamed parameter designed to be used more than once in a single command. For databases that use named or numbered placeholders, the same placeholder is used each time the same object from `Sql.RepeatParam` is used, which could save bandwidth, depending on your database.

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
