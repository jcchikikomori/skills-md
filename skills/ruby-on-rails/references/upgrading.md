# Ruby on Rails Reference

## Upgrading Ruby/Rails

Watch for these breaking changes when upgrading, or when writing new code on a codebase mid-upgrade:

**Ruby 3.x: hash-to-kwargs auto-conversion removed.** Passing a trailing hash to a method that accepts `**kwargs` no longer works implicitly — raises `ArgumentError`.

```ruby
def my_method(arg_1, **options)
  # ...
end

# Invalid in Ruby 3.x (was legal in 2.7):
hash = { a: '1', b: '2' }
my_method(:my_arg_1, hash)
my_method(:my_arg_1, { a: '1', b: '2' })

# Required — also valid in Ruby 2.7, safe to adopt before upgrading:
my_method(:my_arg_1, **hash)          # double-splat
my_method(:my_arg_1, a: '1', b: '2')  # inline keys, no hash wrapper
```

**Rails 7.1+: don't define a custom `with` method.** Rails 7.1 introduces its own `Object#with`, which conflicts with any hand-rolled `with` helper. Replace custom `with` usage with:

- `then { |x| ... }` — runs the block with `x` as `self`.
- `&.then { |x| ... }` — same, but only runs if `self` is not `nil`; use this when the old `with` relied on nil-safety (only yielding when present).
