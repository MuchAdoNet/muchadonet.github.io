---
sidebar_position: 7
---

# Data Mapping

ADO.NET uses the `IDataRecord` interface (and classes derived from it) to represent the data provided when executing a database commands. A data record represents one or more fields, and MuchAdo supports mapping those fields to instances of various types.

:::note
If, when mapping a data record to a type, there are unused fields, e.g. when mapping a data record with two fields to a single integer, MuchAdo will throw an `InvalidOperationException`. If you would rather ignore unused fields, call `WithIgnoreUnusedFields` on the `DbDataMapper` specified by your connector settings.
:::

## Strings

When a field is mapped to `string`, MuchAdo calls the `GetString` method on `IDataRecord`.

```csharp
async Task<IReadOnlyList<string>> GetWidgetNamesAsync(
  DbConnector connector,
  CancellationToken cancellationToken = default)
{
  return await connector.Command("select name from widgets;")
    .QueryAsync<string>(cancellationToken);
}
```

You can also map text to a `TextReader`. Be sure to dispose of the `TextReader` once the text is read.

Be sure to use a nullable `string` (i.e. `string?`) for nullable fields. Since `string` is a reference type, mapping a null field to a non-nullable string will not throw an exception, but the value will be null even though the type is non-nullable.

## Value types

The following value types are mapped by calling `IDataRecord` methods like `GetInt32`: `bool`, `byte`, `char`, `Guid`, `short`, `int`, `long`, `float`, `double`, `decimal`, `DateTime`.

The following types are mapped by calling the `GetFieldValue` method on `DbDataRecord`: `DateTimeOffset`, `sbyte`, `ushort`, `unit`, `ulong`, `TimeSpan`, `DateOnly`, `TimeOnly`. Note that not all ADO.NET providers support these types.

Be sure to use a nullable type for nullable fields. Mapping a null field to a non-nullable value type like `int` will result in an `InvalidOperationException`, since an `int` cannot be null; use `int?` instead.

## Enumerated types

For efficiency, enumerated types are mapped from integers (more specifically, from their underlying type).

Attempting to map text to an enumerated type will throw an exception. To allow text to be parsed as enumerated types, call `WithAllowStringToEnum` on the `DbDataMapper` specified by your connector settings. Keep in mind that a `FormatException` will be thrown if the text fails to parse.

Enumerated types are value types, so be sure to use nullable types when needed.

## Blobs

A blob can be mapped to a `byte[]` or a `Stream`. Be sure to dispose of the `Stream` once it is read.

## DTOs

If the type isn't one of the types listed above or below, it is assumed to be a DTO (data transfer object) type, i.e. a type with properties that correspond to record fields.

```csharp
class WidgetDto
{
  public long Id { get; set; }
  public string? Name { get; set; }
  public double Height { get; set; }
}
```

When a DTO type is used, a new instance of the DTO is created, and each record field is mapped to a DTO property whose name matches the field name, ignoring case and any underscores (so `full_name` would map successfully to `FullName`, for example).

```csharp
IReadOnlyList<WidgetDto> GetWidgets(DbConnector connector) =>
  connector.Command("select id, name, height from widgets;").Query<WidgetDto>();
```

If a DTO property has a `Column` attribute with a non-null `Name` property (e.g. from [System.ComponentModel.DataAnnotations](https://docs.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations.schema.columnattribute)), that name is used instead of the field name.

Not every property of the DTO must be used, but every mapped field must have a corresponding property, unless `WithIgnoreUnusedFields` is used.

Read-only properties can be set if there is a constructor with corresponding parameters.

## Tuples

Use tuples to map multiple record fields at once. Each tuple item is read from the record in order. The record field names are ignored, as are the tuple item names, if any.

```csharp
IReadOnlyList<(string Name, double Height)> GetWidgetInfo(DbConnector connector) =>
  connector.Command("select name, height from widgets;").Query<(string, double)>();
```

Tuples can include multi-field types like DTOs.

```csharp
IReadOnlyList<(WidgetDto Widget, long NameLength)> GetWidgetAndNumber(DbConnector connector) =>
  connector.Command("select id, height, length(name) from widgets;")
    .Query<(WidgetDto, long)>();
```

If the tuple has two or more multi-field types, all but the last must be terminated by a `null` record value whose name is `null`.

```csharp
IReadOnlyList<(WidgetDto Widget, dynamic Etc)> GetWidgetAndDynamic(DbConnector connector) =>
  connector.Command("select id, height, null, 1 as more, 2 as data from widgets;")
    .Query<(WidgetDto, dynamic)>();
```

## object/dynamic

Record fields can be mapped to `object` or `dynamic`. If a single field is mapped to `object` or `dynamic`, the object from `IDataRecord.GetValue()` is returned directly.

```csharp
var heights = connector.Command("select height from widgets;")
  .Query<object>(); // returns boxed doubles
```

If multiple fields are mapped to `object` or `dynamic`, an [`ExpandoObject`](https://docs.microsoft.com/dotnet/api/system.dynamic.expandoobject) is returned where each property corresponds to the name and value of a mapped field.

```csharp
dynamic widget = connector.Command("select name, height from widgets;")
  .Query<dynamic>()[0];
string name = widget.name;
```

:::tip
To avoid confusion, use `object` when mapping a single field and `dynamic` when mapping multiple fields.
:::tip

## Dictionaries

Record fields can also be mapped to a dictionary with a `string` key and any type of value, in which case each field gets a key/value pair in the dictionary. The supported dictionary types are `Dictionary<string, T>`, `IDictionary<string, T>`, `IReadOnlyDictionary<string, T>`, and `IDictionary`.

```csharp
var dictionary = connector.Command("select name, height from widgets;")
  .Query<Dictionary<string, object>>()[0];
double height = (double) dictionary["height"];
```

## Mapping delegate

For more control over the mapping, the client can specify the `map` parameter, which is of type `Func<DbConnectorRecord, T>`. That delegate will be called for each data record returned by the query. Use one of the `Get<T>` methods to map one or more fields to the specified type.

```csharp
IReadOnlyList<double> GetWidgetHeights(DbConnector connector) =>
  connector.Command("select name, height from widgets;")
    .Query(x => x.Get<double>(1));
```

Fields can also be accessed by name, though that uses [`IDataRecord.GetOrdinal()`](https://docs.microsoft.com/dotnet/api/system.data.idatarecord.getordinal) and is thus slightly less efficient.

```csharp
IReadOnlyList<double> GetWidgetHeights(DbConnector connector) =>
  connector.Command("select name, height from widgets;")
    .Query(x => x.Get<double>("height"));
```

You can also read multiple fields.

```csharp
IReadOnlyList<(string Name, double Height)> GetWidgetInfo(DbConnector connector) =>
  connector.Command("select id, name, height from widgets;")
    .Query(x => x.Get<(string, double)>(index: 1, count: 2));
```

C# 8 range syntax can be used:

```csharp
IReadOnlyList<(string Name, double Height)> GetWidgetInfo(DbConnector connector) =>
  connector.Command("select id, name, height from widgets;")
    .Query(x => x.Get<(string, double)>(1..3));
```

You can also use the delegate to avoid the `null` terminator when reading two or more multi-field types. To avoid having to count fields, we can use a `Get<T>()` overload that takes a start name and an end name to specify the range.

```csharp
IReadOnlyList<(WidgetDto Widget, dynamic Etc)> GetWidgetAndDynamic2(DbConnector connector) =>
  connector.Command("select id, height, 1 as more, 2 as data from widgets;")
    .Query(x => (x.Get<WidgetDto>("id", "height"), x.Get<dynamic>("more", "data")));
```

## Custom mapping

To directly support types not mentioned above, you can create a custom mapping:

* Derive a class from `DbTypeMapper<T>`, overriding the `FieldCount` and `MapCore` methods.
* Derive a class from `DbTypeMapperFactory`, overriding `TryCreateTypeMapper<T>` and returning an instance of your type mapper when the type matches.
* Create a `With` extension method that adds an instance of your type mapper factory to a `DbDataMapper` instance.
* Call that extension method on your default data mapper and assign the returned data mapper to the `DataMapper` connector setting.
