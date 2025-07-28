---
sidebar_position: 10
---

# Resilience

MuchAdo has features to help you recover from deadlocks and other transient errors.

## Retry connections

To automatically retry opening a database connection when it throws a transient exception, set the `RetryPolicy` connector setting.

You can derive a class from the abstract `DbRetryPolicy` class, but it is simpler to add a reference to the [MuchAdo.Polly](https://www.nuget.org/packages/MuchAdo.Polly) NuGet package and use `PollyDbRetryPolicy.Create` to create an instance from a Polly resilience pipeline.

## Retry transactions

To use the retry policy to retry an auto-commit transaction, call `RetryInTransactionAsync` instead of `ExecuteInTransactionAsync`.

## Retry commands

To use the retry policy to retry a command or command batch, chain a call to `Retry` before executing the command. It is up to you to ensure that a multi-command batch is idempotent, since it may be called more than once, per the retry policy. You can wrap it in a transaction if necessary, e.g. by chaining a call to `InTransaction`. Use `RetryInTransaction` as shorthand for calling both `Retry` and `InTransaction`.

## Retry any action

To use the retry policy with any action, call `RetryAsync`. It is up to you to ensure that the called code is idempotent, since it may be called more than once, per the retry policy.
