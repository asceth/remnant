Remnant hooks into your Rails and discovers your hidden statistics.

##### Supports

* Rails 2.3.x

#### What Remnant Captures
* request - time it takes for a request to be served
* action - time it takes for the controller action to finish
* view - total time for the totality of render to complete
* templates - time it takes for each template/partial to render
* filters - time it takes for each filter to run
* db - total time it takes for all queries to execute
* queries - time it takes for each sql query to execute
* gc - time spent inside the GC (if avaialble ree, 1.9.3, etc)

These stats are sent to statsd:
request, action, view, gc, db, filters


#### Install

```
$ [sudo] gem install remnant
```

```ruby
# For Rails 2.3.x
gem 'remnant'
```


#### Usage


Add an initializer to configure (or call configure during application startup):

```ruby
Remnant.configure do
  # hostname of statsd server
  host "https://remnant.statsd"

  # port of statsd server
  port 8125

  # app name or other unique key for multiple app usage
  tagged "custom"

  # environment of application, defaults to Rails.env
  # included in payload
  environment "production"

  hook do |results|
    # custom hook to run after each remnant capture with results
    # results = {key => ms, key2 => ms2}
  end
end

Remnant::Rails.setup! # needed if on Rails 2.3.x
```

If you want to capture the times it takes to render templates/partials you
should enable Template capturing in a before filter (or before rendering
takes place)
```ruby
before_filter {|c| Remnant::Template.enable! }
```

If you want to capture the sql query times you should enable Database
capturing in a before filter (or before rendering takes place)
```ruby
before_filter {|c| Remnant::Database.enable! }
```


#### Example of using hook
Below is a way to use all captured information remnant offers
```ruby
hook do |results|
  results.map do |key, ms|
    # loop through specially captures results
    # [request, action, view]
  end

  # total time for db
  Remnant::Database.total_time.to_i

  # total time for all filters
  Remnant::Filters.total_time.to_i

  # time for individual filters
  # [{:type => 'before|after|round',
  #   :name => filter_name,
  #   :time => microseconds,
  #   :ms => ms
  # }]
  Remnant::Filters.filters.to_json

  # time for individual templates/partials
  # [view => {'time' => ms,
  #           'exclusive' => ms,
  #           'depth' => depth,
  #           'children' => []
  # }]
  if Remnant::Template.enabled?
    Remnant::Template.trace.root.children.map(&:results).to_json
  end

  # time for sql queries
  if Remnant::Database.enabled?
    queries = Remnant::Database.queries.map {|q| {:sql => q.sql, :ms => q.time * 1000}}
  end

  # time spent in GC and number of collection attempts
  Remnant::GC.time.to_i
  Remnant::GC.collections.to_i
end
```
###### Note
Remnant logs to statsd only if your environment is production, demo or staging.
For all other environments it logs via Rails.logger.info

#### Author


Original author: John "asceth" Long
