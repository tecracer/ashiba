# Ashiba

Ashiba is yet another Ruby-based scaffolding tool. It allows bootstrapping of
projects using precreated templates. Templates for projects can be authored
as separate Rubygems to allow maximum flexibility and central management.

Ashiba (足場) is Japanese for scaffolding and meand as a nod towards the
Ruby language, which originated in Japan.

## Installation

Install the tool with

```bash
gem install 'ashiba'
```

## Template Authoring

A generator for templates is included under the name `ashiba-template`. With
this, you can create you own custom generators for Rubygems, Chef Cookbooks
or whatever you want.

Every template has a configuration file in YAML which states some metadata
along with the template's variables and their defaults like this:

```yaml
variables:
  name: ''
  version: 0.1.0
```

All files within a template are parsed as ERB, so you can substitute
things with variables (`<%= name + ' ' + version %>`) or execute Ruby code for
looping or anything else (`<% do_something() %>`).

If you want to use the content of a variable in a filename, just enclose it in
percent signs: `%name%.gemspec`.

All templates are directly configured as Gem file, so you can build them,
install them and even publish them to your own private Gem repository or
rubygems.org.

### Final commands

If you want commands to be executed after scaffolding your project, add them as
a list under the `finalize` key of the YAML

## Configuration

Ashiba YAML configuration files reside in ~/.ashibarc or in /etc/ashiba/ashibarc.

You currently can only override template defaults with a file like

```yaml
author: My Name
email: name@example.com
```

which will override the author/email variable defaults from the template. So if
you have this in your home directory or the system configuration directory,
all template executions will default to your name and email.

## Usage

`ashiba help` Display all available commands

`ashiba list` List all available templates on the system

`ashiba info TEMPLATE` Display metadata about a template

`ashiba create TEMPLATE PATH [--set variable:value]` Scaffold a package
Note that you can manually specify contents of variables. Lookup will happen
in order `/etc/ashiba/ashibarc`, `~/.ashibarc`, `--set` value or template
default.

`ashiba version` Output version of Ashiba
