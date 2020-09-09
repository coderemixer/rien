# Rien

Ruby IR Encoding Gem (Experimental)

# Example

```
Usage: rien [options]
    -e, --encode [FILE]              Encode specific ruby file
    -p, --pack [DIR]                 Pack ruby directory into encoded files
    -o, --out [FILE/DIR]             Indicate the output of the encoded file(s)
    -u, --use-rienfile               Use Rienfile to configure, override other options
    -s, --silent-mode                Suppress all prompts asking for user input
    -t, --tmpdir [DIR]               Select a temp directory to store intermediate results
```

## Encode Mode

Encode single ruby file

```ruby
# hello.rb

puts "Hello Rien"
```

```
rien -e hello.rb -o encoded.rb

ruby encoded.rb # => Hello Rien
```

## Pack Mode

### Compile all .rb files in the directory

```
rien -p source -o output
```

### Use Rienfile to configure

When using `Rienfile` to configure, other options from CLI will be ignored

Put a `Rienfile` in your project directory

```ruby
# source/Rienfile

Rien.configure do |config|
    # The syntax is the same as glob used in class Dir
    # [Optional] includes all files by default
    config.includes = ["app/**/*", "lib/**/*"]
    # [Optional] excludes nothing by default
    config.excludes = ["**/*.py",
                       "lib/**/templates/**/*",
                       "**/init.rb"]

    # [Optional] set to rien_output by default
    config.output = "compiled"

    # Rien will wait user to input in console when 
    # finding suspicious already compiled file
    # set this to true to turn it off
    # [Optional] set to false by default
    config.silent = false

    # [Optional] use Dir.tmpdir/rien by default
    # aka. /tmp/rien for linux
    config.tmpdir = "tmpdir/rien"

end
```

and then

```
rien -p source -u
```
### Files to be excluded

#### Read file and eval

Real world code from [redmine/config/initializers/00-core_plugins.rb
](https://github.com/redmine/redmine/blob/master/config/initializers/00-core_plugins.rb#L14)

```ruby
eval(File.read(initializer), binding, initializer)
```

Compile `lib/plugins/**/init.rb` may lead to a such error in runtime
```
init.rb:5:in `<main>': undefined local variable or method `config' for main:Object (NameError)
```

Use `Rinefile` to exclude `lib/plugins/**/init.rb`

### Temporary directory

Rien uses a `tmpdir` to store intermediate results and timestamps to distinguish them.

Check your `tmpdir` (`/tmp/rien` for linux by default) to clean unsuccessful build results.
