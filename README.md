# Hashape

Hashape is a **lightweight library for testing the structure of hashes**. It
supports deep nesting and a variety of different methods of matching types or
values (called _specifiers_).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hashape'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hashape

## Usage

First, you can define your shape using `Hashape.shape`, which returns an
instance of `Hashape::Shape`.
Each key must be given a specifier, which can be one of the following:

  - A type
  - Simple values (e.g. strings, booleans, numbers)
  - Another hash
  - Regular expressions
  - An instance of any class in `Hashape::Specifiers`

(Fundamentally, comparisons are done using `===` with your specifier on the left
hand side, so anything which supports this will work.)

You can then check that a given hash matches this shape using either 
`Shape#matches?`, which returns a boolean, or `Shape#matches!`, which raises an
exception if the shape does not match.

Here's an example of checking that a hash has a `:name` key which is a string,
and a `:success` key which must be true:

```
require 'hashape'
include Hashape

shape = Shape.new({
  name: String,
  success: true
})

p shape.matches?({
  name: 'Aaron',
  success: true
}) #=> true

p shape.matches?({
  name: 'Aaron',
  success: false
}) #=> false

shape.matches!({
  name: 3,
  success: true
}) #=> ShapeMatchError (key name with value 3 does not match spec String)
```

Extra specifiers, which are within the `Hashape::Specifiers` module, give you 
a bit more flexibility. They wrap another specifier (or an array of them) to
alter their behaviour. (Note that you can nest specifiers.) For example:

```
require 'hashape'
include Hashape
include Hashape::Specifiers

# Note: for all specifiers, Name[...] is a shortcut for Name.new(...).

shape = Shape.new({
  data: Optional[String]
})
shape.matches?({ data: "Hello!" }) #=> true
shape.matches?({ }) #=> true
shape.matches?({ data: 3 }) #=> false
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).