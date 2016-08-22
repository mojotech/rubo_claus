# RuboClaus

RuboClaus is an open source project that gives the Ruby developer a DSL to implement functions with multiple clauses and varying numbers of arguments on a pattern matching paradigm, inspired by functional programming in Elixir and Erlang.

#### Note

_RuboClaus is still in very early stage of development and thought process.  We are still treating this as a proof-of-concept and are still exploring the topic.  As such, we don't suggest you use this in any kind of production environment, without first looking at the library code and feeling comfortable with how it works.  And, if you would like to continue this thought experiment and provide feedback/suggestions/changes, we would love to hear it._

### Rationale

The beauty of multiple function clauses with pattern matching is fewer conditionals and fewer lines of unnecessary defensive logic. Focus on the happy path. Control types as they come in, and handle for edge cases with catch all clauses. It does not work great for simple methods, like this:

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
    clause([Fixnum, Fixnum], proc { |first, second| first + second }),
    catch_all(proc { "Please use numbers" })
  )
end
```

It is cumbersome for problems like `add`--in which case we don't recommend using it. But as soon as we add complexity that depends on parameter arity or type, we can see how RuboClaus makes our code more extendible and maintainable. For example:

Ruby:

```ruby
def handle_response(status, has_body, is_chunked)
  if status == 200 && has_body && is_chunked
    # ...
  else
    if status == 200 && has_body && !is_chunked
      # ...
    else
      if status == 200 && !has_body
        # ...
      else
        # ...
      end
    end
  end
end
```

Ruby with RuboClaus:

```ruby
define_function :handle_response do
  clauses(
    clause([200, true, true], proc { |status, has_body, is_chunked| ... }),
    clause([200, true, false], proc { |status, has_body, is_chunked| ... }),
    clause([200, false], proc { |status, has_body| ... }),
    catch_all(proc { return_error })
  )
end
```
[Credit](https://www.reddit.com/r/elixir/comments/34jyto/what_are_the_benefits_of_pattern_matching_as/cqve33n)

To learn more about this style of programming read about [function overloading](https://en.wikipedia.org/wiki/Function_overloading) and [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching).

## Usage

Below are the public API methods and their associated arguments.

* `define_function`
	* Symbol - name of the method to define
	* Block - a single block with a `clauses` method call
* `clauses`
	* N number of `clause` method calls and/or a single `catch_all` method call
* `clause` | `p_clause`
	* Array - list of arguments to pattern match against
      * Keywords:
        * `:any` - among your arguments, `:any` represents that any data type will be accepted in its position.
        * `:tail` - given an array argument with defined "head" elements and `:tail` as the last element (such as `[String, String, :tail]`), this will destructure the head elements and make the tail an array of the non-head elements.
	* Proc - method body to execute when this method is matched and executed
    * Note on `p_clause` - only visible to other clauses in the function, and will return `NoPatternMatchError` if invoked with matching parameters external to the function. Ideally used when calling the function recursively with different arity than the public api to the method.
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

You also can destructure an array with `:tail`.

```ruby
clause(["Hello", [Fixnum, :tail]], proc { |string, number, tail_array| ...  })
clause([Hash, [Fixnum, Fixnum :tail]], proc { |hash, number1, number2,  tail_array| ... })
```



### Examples

Please see the [examples directory](https://github.com/mojotech/rubo_claus/tree/master/examples) for various example use cases.  Most examples include direct comparisons of the Ruby code to a similar implementation in Elixir.

## Development

Don't introduce unneeded external dependencies.

Nothing else special to note for development.  Just add tests associated to any code changes and make sure they pass.

---

[![Build Status](https://travis-ci.org/mojotech/rubo_claus.svg?branch=master)](https://travis-ci.org/mojotech/rubo_claus)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)
