# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup          # Install dependencies
bin/console        # Open IRB session with the gem loaded (for manual testing)
bundle exec rake   # Run default rake tasks
gem build          # Build the .gem file
```

No test framework is configured. If tests are added, update this file with the test command.

## Architecture

A Ruby gem wrapping the [OpenFIGI V3 API](https://www.openfigi.com/api) — a financial data service for mapping identifiers (ISIN, CUSIP, ticker, etc.) to FIGIs (Financial Instrument Global Identifiers). V3 only; V2 is sunsetting.

**Base URL:** `https://api.openfigi.com/v3`
**Auth:** optional `X-OPENFIGI-APIKEY` header
**Rate limits:** 25 req/min (unauthenticated) · 25 req/6s (authenticated) for mapping; lower limits for search/filter

### Module layout

```
lib/openfigi_ruby.rb              # Entry point: requires all sub-files, exposes .configure
lib/openfigi_ruby/
  version.rb                      # VERSION constant
  configuration.rb                # Configuration (api_key, open_timeout, read_timeout)
  error.rb                        # Error hierarchy (see below)
  client.rb                       # HTTP client — all API methods live here
  figi_result.rb                  # FigiResult Struct (one matched instrument)
  mapping_result.rb               # MappingResult Struct (data array or warning)
  search_result.rb                # SearchResult and FilterResult Structs
```

### Client API

```ruby
OpenfigiRuby.configure { |c| c.api_key = ENV["OPENFIGI_API_KEY"] }
client = OpenfigiRuby::Client.new   # uses global config; accepts api_key: override

client.mapping([{ id_type: "ID_ISIN", id_value: "US4592001014" }])
  # => [MappingResult(data: [FigiResult(...)], warning: nil)]

client.mapping_values(:id_type)
  # => ["ID_ISIN", "ID_CUSIP", ...]

client.search(query: "Apple", exch_code: "US")
  # => SearchResult(data: [...], next_page: "...", error: nil)

client.filter(query: "Apple", currency: "USD")
  # => FilterResult(data: [...], next_page: "...", total: 42, error: nil)
```

All input hashes use **snake_case** symbol keys; the client converts to camelCase for the API. Response structs use snake_case accessors. `next_page` holds the pagination token (the API field is `next`).

### Error hierarchy

```
OpenfigiRuby::Error
  └─ ApiError          (status_code:, body: attributes)
       ├─ AuthenticationError   # HTTP 401
       ├─ RateLimitError        # HTTP 429
       ├─ InvalidRequestError   # HTTP 400
       └─ ServerError           # HTTP 500/503
```

### Conventions

- All files use `# frozen_string_literal: true`
- Ruby >= 3.1.0 required
- No runtime dependencies — uses only `net/http`, `json`, `uri` from stdlib
- Runtime dependencies go in `openfigi_ruby.gemspec`; dev-only in `Gemfile`
- Version is the single source of truth in `lib/openfigi_ruby/version.rb`
