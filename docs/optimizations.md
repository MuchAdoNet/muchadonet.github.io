---
sidebar_position: 10
---

# Optimizations

MuchAdo has features to help you potentially get better performance from your database queries.

## Prepared Commands

Call `Prepare` before executing a command if you want MuchAdo to call `PrepareAsync` on the ADO.NET command object before executing it.

If you want to automatically prepare all commands, use the `PrepareCommands` connector setting.

## Cached Commands

Call `Cache` before executing a command if you want MuchAdo to cache the ADO.NET command and parameter objects after executing a command. The next time the connector executes a command with the exact same SQL, MuchAdo will reuse the command and parameter objects rather than recreate them. The ADO.NET objects are cached indefinitely with the `DbConnector` object, so avoid caching commands that will only be executed once.

If you want to automatically cache all commands, use the `CacheCommands` connector setting.

## Connector Pooling

Use `DbConnectorPool` to create connectors if you want to reuse them. This can be helpful with ADO.NET providers that don't do connection pooling. It also extends the life of cached commands, since they are stored with the pooled connector.
