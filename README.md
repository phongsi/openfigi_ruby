# OpenfigiRuby

[![Gem Version](https://badge.fury.io/rb/openfigi_ruby.svg)](https://badge.fury.io/rb/openfigi_ruby)
[![CI](https://github.com/phongsi/openfigi_ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/phongsi/openfigi_ruby/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

Ruby client for the [OpenFIGI V3 API](https://www.openfigi.com/api). Maps financial identifiers (ISIN, CUSIP, ticker, etc.) to FIGIs (Financial Instrument Global Identifiers), with support for keyword search and filtering.

## Installation

```bash
bundle add openfigi_ruby
```

Or add to your Gemfile manually:

```ruby
gem "openfigi_ruby"
```

## Usage

### Configuration

```ruby
OpenfigiRuby.configure do |config|
  config.api_key = ENV["OPENFIGI_API_KEY"]  # optional but recommended for higher rate limits
  config.open_timeout = 10                  # seconds (default: 10)
  config.read_timeout = 30                  # seconds (default: 30)
end

client = OpenfigiRuby::Client.new
```

You can also pass an API key per-client without touching global config:

```ruby
client = OpenfigiRuby::Client.new(api_key: "your_key")
```

---

### Mapping identifiers to FIGIs

`mapping` accepts up to 10 jobs per request (100 with an API key) and returns one result per job.

```ruby
results = client.mapping([
  { id_type: "ID_ISIN",  id_value: "US0378331005" },
  { id_type: "ID_CUSIP", id_value: "037833100" },
  { id_type: "TICKER",   id_value: "AAPL", exch_code: "US" },
])

results.each do |result|
  if result.found?
    result.data.each do |figi|
      puts "#{figi.name} — #{figi.figi} (#{figi.exch_code})"
    end
  else
    puts "No match: #{result.warning}"
  end
end
```

**Optional filters per job:**

| Key | Description |
|---|---|
| `:exch_code` | Exchange code (e.g. `"US"`, `"LN"`) |
| `:mic_code` | Market Identifier Code |
| `:currency` | Currency code (e.g. `"USD"`) |
| `:market_sec_des` | Market sector description |
| `:security_type` | Primary security type |
| `:security_type2` | Secondary security type (required for `BASE_TICKER`/`ID_EXCH_SYMBOL`) |
| `:include_unlisted_equities` | Boolean |
| `:option_type` | `"Put"` or `"Call"` |
| `:strike` | Two-element numeric range, e.g. `[100, 150]` |
| `:expiration` | Two-element date range, e.g. `["2024-01-01", "2024-12-31"]` |
| `:maturity` | Two-element date range (required for Pool) |
| `:state_code` | US state code |

---

### Fetching valid enum values

Look up the accepted values for any filterable field:

```ruby
client.mapping_values(:id_type)
# => ["ID_ISIN", "ID_CUSIP", "TICKER", "ID_BB_GLOBAL", ...]

client.mapping_values(:exch_code)
# => ["US", "LN", "UN", ...]
```

Valid keys: `:id_type`, `:exch_code`, `:mic_code`, `:currency`, `:market_sec_des`, `:security_type`, `:security_type2`

---

### Keyword search

Search for FIGIs by name or ticker. Results are paginated.

```ruby
result = client.search(query: "Apple", exch_code: "US", security_type: "Common Stock")

result.data.each { |figi| puts "#{figi.ticker} — #{figi.figi}" }

# Fetch the next page
if result.next_page
  result = client.search(query: "Apple", exch_code: "US", start: result.next_page)
end
```

---

### Filter

Like search, but results are sorted alphabetically by FIGI and include a total count. Query is optional.

```ruby
result = client.filter(currency: "USD", security_type: "Common Stock")

puts "#{result.total} total matches"
result.data.each { |figi| puts figi.figi }

# Paginate
while result.next_page
  result = client.filter(currency: "USD", security_type: "Common Stock", start: result.next_page)
  result.data.each { |figi| puts figi.figi }
end
```

---

### Error handling

```ruby
begin
  results = client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])
rescue OpenfigiRuby::AuthenticationError
  # HTTP 401 — check your API key
rescue OpenfigiRuby::RateLimitError
  # HTTP 429 — back off and retry
rescue OpenfigiRuby::InvalidRequestError => e
  # HTTP 400 — malformed request
  puts e.body
rescue OpenfigiRuby::ServerError
  # HTTP 500/503 — retry with exponential backoff
rescue OpenfigiRuby::ApiError => e
  # catch-all for any other non-200 response
  puts "#{e.status_code}: #{e.message}"
end
```

---

### Rate limits

| | Without API key | With API key |
|---|---|---|
| **Mapping** | 25 req/min, 10 jobs/req | 25 req/6s, 100 jobs/req |
| **Search/Filter** | 5 req/min | 20 req/min |

Get a free API key at [openfigi.com](https://www.openfigi.com/api#get-started).

## Development

```bash
bin/setup          # install dependencies
bin/console        # interactive prompt with the gem loaded
bundle exec rake   # run tests
bundle exec yard server  # browse docs at http://localhost:8808
```

## License

[MIT](LICENSE.txt)
