# Api
Remedy includes a complete implementation of the endpoints supported by Discord's
API. Method names are copied closely from the documentation to eliminate any
confusion about what a method does, as well as allow users to easily lookup the
endpoints in the official API documentation.

For a full listing of method definitions, please see `Remedy.Api`

## What does the '!' mean?
(soon™) All methods have a `banged` version of themselves. This is a common Elixir
idiom hailing from Elixir's style of failing fast.

By default, the API method will return a tuple like one of the following:
```Elixir
# Success
{:ok, msg} = Remedy.Api.create_message(179679229036724225, "456")

# Failure
{:error, reason} = Remedy.Api.create_message(123, "eat my shorts api")
```

A banged method, instead of returning an `error` tuple, will throw an error.
If successful, it will directly return the response with no `:ok` tuple.
```Elixir
# Success
msg = Remedy.Api.create_message!(179679229036724225, "456")

# Failure - Throws an error
Remedy.Api.create_message!(123, "eat my shorts api")
```

## Helpers
When appropriate, some helpers are defined to make interacting with the API simpler.
An example of this is `Remedy.Api.get_channel_messages/3`. By default this endpoint
only allows the retrieval of `100` messages at a time. A general use case will
have a user wanting more messages than that, thus Remedy handles the retrieval
of any number of messages for the user.

There are other endpoints that could use grooming like above, feel free to suggest
an interface and implementation for these methods.

## Ratelimiting
Ratelimiting is handled internally by Remedy, so long as you use the methods
supplied in the `Remedy.Api` module. This means either calling the methods as
they're given or using `Remedy.Api.request/4` to call an endpoint.

To ensure that every request is handled properly, no matter if they're called
asynchronously or not, Remedy funnels all requests through a single `GenServer`.

The ratelimiter at a high level works something like this:

 1. Request is sent to the serializer
 2. Serializer checks to see if there's a current block on that endpoint.
  1. If there is a block, the pid of the caller is stored, and a task is started
  to try the call again after a specified time stored from previous calls.
 3. If the request goes through, the headers are processed to see if a block
 should be instantiated for that endpoint.

## Rest Only
If you only want to use the REST portion of the provided API, the only process
needed is the ratelimiter. This can be manually started by calling
`Remedy.Api.Ratelimiter.start_link/1`. If you don't want to start Remedy you
can add `runtime: false` to the dependency options.
