# RuboClaus

RuboClaus is an open source project that gives the Ruby developer a DSL to implement functions with multiple clauses and varying numbers of arguments on a pattern matching paradigm, inspired by functional programming in Elixir and Erlang.

#### Note

_RuboClaus is still in very early stage of development and thought process.  We are still treating this as a proof-of-concept and are still exploring the topic.  As such, we don't suggest you use this in any kind of production environment, without first looking at the library code and feeling comfortable with how it works.  And, if you would like to continue this thought experiment and provide feedback/suggestions/changes, we would love to hear it._

### Rationale

The beauty of multiple function clauses with pattern matching is fewer conditionals and fewer lines of unnecessary defensive logic. Focus on the happy path. Control types as they come in, and handle for edge cases with catch all clauses.

Ruby:

```ruby
def add(first, second)
  return "Please use numbers" unless [first, second].all? { |obj| obj.is_a? Fixnum }
  first + second
end
```

Ruby With RuboClaus:

```ruby
define_function :add do
  clauses(
    clause([Fixnum, Fixnum], proc do |first, second|
      first + second
    end), # This clause controls type and arity so that you can focus on elegant logic.
    catch_all(proc { "Please use numbers" }
  )
end
```

You may think that this is cumbersome at first. But as soon as we add some complexity to the method, we can see how RuboClaus makes our code more extendible and maintainable.

## Usage

Below are the public API methods and their associated arguments.

* `define_function`
	* Symbol - name of the method to define
	* Block - a single block with a `clauses` method call
* `clauses`
	* N number of `clause` method calls and/or a single `catch_all` method call
* `clause`
	* Array - list of arguments to pattern match against
	* Proc - method body to execute when this method is matched and executed
* `catch_all`
	* Proc - method body that will be executed if the arguments do not match any of the `clause` patterns defined

### Clause pattern arguments

The first argument to the `clause` method is an array of pattern match options.  This array can vary in length, and values depending on your pattern match case.

You can match against specific values:

```ruby
clause(["foo"], proc {...})
clause([42], proc {...})
clause(["Hello", :darth_vader], proc {...})
```

You can match against specifc argument types:

```ruby
clause([String], proc {...})
clause([Fixnum], proc {...})
clause([String, Symbol], proc {...})
```

You can match against specific values and types:

```ruby
clause(["Hello", String], proc {...})
clause([42, Fixnum], proc {...})
clause([String, :darth_vader], proc {...})
```

You also can match against any value or type if you don't have a specific requirement for an argument by using the `:any` symbol.

```ruby
clause(["Hello", :any], proc {...})
clause([:any], proc {...})
clause([42, :any], proc {...})
```



### Examples

Please see the [examples directory](https://github.com/mojotech/rubo_claus/tree/master/examples) for various example use cases.  Most examples include direct comparisons of the Ruby code to a similar implementation in Elixir.

## Development

Don't introduce unneeded external dependencies.

Nothing else special to note for development.  Just add tests associated to any code changes and make sure they pass.

## TODO

[ ] Rename public API methods? `define_function` is awkward since Ruby uses the term `method` instead of `function`
[ ] Add Benchmarks to see performance implications

---

[![Build Status](https://travis-ci.org/mojotech/rubo_claus.svg?branch=master)](https://travis-ci.org/mojotech/rubo_claus)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)
