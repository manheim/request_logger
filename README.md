#Request Logger
=======
This is a verbose request logger to be used in any rack based ruby application.

=======
To Use:

```ruby
use RequestLogger, log: <logger>, [filter: ["sample\_header"], correlation\_header: "correlation_header"]
```

log: requires a logger that responds to the standard ruby logger object methods (info, debug, etc.)
filter: an array of header names not to be logged, generally used to prevent authentication information from being logged
correlation_header: the header value to use for a correlation value (default: correlation\_id)

note: for all header values, the HTTP\_ prefix can be ignored, and the matching is case insensitive.

The gem will also provide a correlation_id value into the Logging mdc as well as add it as a return header.

This value can then be used in logging formatters to include the correlation_id in all logs:

```ruby
Logging.layouts.pattern(:pattern => "[##{MyApp::VERSION}] - [%d] %-5l: %X{correlation_id} - %m\n")
```

This will generate a log like:

```
[#dev] - [2016-02-29 12:28:15] INFO : <correlation_id> - Response: 201 {"Content-Type"=>"application/json", "location"=>"http://127.0.0.1/objects", "Content-Length"=>"0"} [response_body]
```

By Combining the correlation header and the correlation return header, this can be used to find logs across applications using a single value.