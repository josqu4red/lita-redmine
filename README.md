# lita-redmine

**lita-gerrit** is a handler for [Lita](https://github.com/jimmycuadra/lita) that allows interaction with Redmine project management tool (or its fork, Chiliproject).

## Installation

Add lita-redmine to your Lita instance's Gemfile:

``` ruby
gem "lita-redmine"
```

## Configuration

* `url` (String) - Redmine service URL
* `type` (Symbol) - Redmine variant used (`:redmine` or `:chiliproject`)
* `apikey` (String) - Key for REST API access

### Example

```ruby
Lita.configure do |config|
  config.handlers.redmine.url = "https://redmine.example.com"
  config.handlers.redmine.type = :redmine
  config.handlers.redmine.apikey = "0000000000000000000000000000000000000000"
end
```
## Usage

```
lita > redmine 42
https://redmine.example.com/issues/21206 : Chef-ize powerdns instalation
```
## License

[MIT](http://opensource.org/licenses/MIT)
