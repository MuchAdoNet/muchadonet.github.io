---
sidebar_position: 9
---

# Parameters

The simplest way to specify command parameters is to use [formatted SQL](./formatted-sql.md) to inject parameter values into the SQL statement.

```csharp
var widgetId = await connector
    .CommandFormat($"select id from widgets where name = {name}")
    .QuerySingleAsync<long>();
```

This may look like a potential SQL injection vulnerability, but it is not, since the injected value is replaced with a parameter placeholder in the SQL statement, and the value itself is passed to the command via matching parameter. The exact syntax of the parameter placeholder depends on the database provider; by default, it uses arbitrarily named parameters like `@ado1` and `@ado2`, but some providers use `$1` and `$2` or even just `?`.

## Collection Parameters

Using formatted SQL with a collection will create one parameter whose value is the collection. If you want to expand a non-empty collection into a parenthesized set of parameters for use with the `IN` keyword, use the `set` format specifier.

```csharp
var widgetsFromIds = await connector
    .CommandFormat($"""
        select id, name, height from widgets
        where id in {widgetIds:set}
        """)
    .QueryAsync<Widget>();
```

## Parameter Sources

When the simple techniques above aren't sufficient, you can use a parameter source, which is derived from `SqlParamSource` and represents an ordered collection of parameters, named or unnamed.

A parameter source can be injected into formatted SQL or included as command arguments. When injected into formatted SQL, a parameter source generates placeholders for parameters with the corresponding values, comma-separated in the SQL if there are more than one. See below for examples.

### Unnamed Parameters

`Sql.Param` creates a parameter source containing a single unnamed parameter with the specified value.

```csharp
widgetId = await connector
    .Command("select id from widgets where name = ?", Sql.Param(name))
    .QuerySingleAsync<long>();
```

`Sql.RepeatParam` creates an unnamed parameter designed to be used more than once in the formatted SQL of a single command. For databases that use named or numbered placeholders, the same placeholder is used each time the same object from `Sql.RepeatParam` is used, which could be more efficient.

```csharp
var heightParam = Sql.RepeatParam(height);
await connector
    .CommandFormat($"""
        insert into widgets (name, height)
        values ({name}, {heightParam})
        on duplicate key update height = {heightParam}
        """)
    .ExecuteAsync();
```

`Sql.Params` generates unnamed parameters from a collection. The collection is not copied; parameters are generated from the items when the command is executed. If the collection is empty, empty SQL will be produced, which could result in invalid SQL. Generally, you should check for an empty collection and bypass the command or add a conditional to generate valid SQL for that case. The `set` format specifier documented above is normally simpler, but this is equivalent to the example above:

```csharp
widgetsFromIds = await connector
    .CommandFormat($"""
        select id, name, height from widgets
        where id in ({Sql.Params(widgetIds)})
        """)
    .QueryAsync<Widget>();
```

### Named Parameters

Unnamed parameters are simplest, but you can also create named parameters. Be sure to avoid specifying two different parameters with the same name in the same command.

`Sql.NamedParam` creates a parameter with the specified name and value. When injected into formated SQL, named parameters use the corresponding named placeholder, e.g. `@height`.

```csharp
widgetId = await connector
    .CommandFormat($"""
        select id from widgets
        where name = {Sql.NamedParam("name", name)}
        """)
    .QuerySingleAsync<long>();
```

Alternatively:

```csharp
widgetId = await connector
    .Command("select id from widgets where name = @name",
        Sql.NamedParam("name", name))
    .QuerySingleAsync<long>();
```

Named parameters can also be useful when calling stored procedures.

```csharp
await connector
    .StoredProcedure("create_widget",
        Sql.NamedParam("widget_name", name),
        Sql.NamedParam("widget_height", height))
    .ExecuteAsync();
```

`Sql.NamedParams` creates multiple parameters with the specified names and values, either from a collection of tuple pairs where the first value is the parameter name, or from a collection of key/value pairs where the key is the parameter name. As with `Sql.Params`, you should usually avoid empty collections.

```csharp
var namedParams = Sql.NamedParams(widgetIds.Select((x, i) => ($"id{i}", x)));
widgetsFromIds = await connector
    .CommandFormat($"""
        select id, name, height from widgets
        where id in ({namedParams})
        """)
    .QueryAsync<Widget>();
```

### DTOs

`Sql.DtoColumnNames` is useful when selecting fields to map to a DTO.

Use `From` when you're using an explicit table name or alias.

`Sql.DtoParams` generates unnamed parameters for the value of each property of a DTO. It is often used with `Sql.DtoColumnNames` when inserting database records.

In both cases, you can use `Where` to filter properties by name.

If you prefer named parameters, you can use `Sql.DtoNamedParams`.

To add a prefix or suffix to help ensure that the parameter name is unique, use `Renamed`.

If you want to manually generate parameter placeholders for a DTO, use `Sql.DtoParamNames`.

To filter out parameters by name, use `Where`.

To transform the names of the parameters, use `Renamed`.

If you are calling a stored procedure that requires parameters, you can use the same methods that are documented in [formatted SQL](./formatted-sql.md), but include the parameter sources as arguments after the stored procedure name.

You can do the same if you are executing a command but adding the parameter placeholders yourself.

A `SqlParamSource` represents a list of parameters. It derives from `SqlSource`, and when one used as a SQL fragment, it generates parameter placeholders for parameters with the corresponding values, comma-separated in the SQL if there are more than one. See [Parameters](./parameters.md) for more information about `SqlParamSource`.

The returned object is of type `SqlParam<T>`, which has a `Value` property that can be set, if you want to reuse the object for multiple commands to reduce allocation.
