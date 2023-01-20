---
title: Pretty Location
---

The [`pretty_location`][pretty_location] plugin attempts to generate a nicer
folder structure for uploaded files.

```rb
plugin :pretty_location
```

This plugin uses the context information from the Attacher to try to generate a
nested folder structure which separates files for each record. The newly
generated locations will typically look like this:

```rb
"user/564/avatar/thumb-493g82jf23.jpg"
# :model/:id/:attachment/:derivative-:uid.:extension
```

By default if a record class is inside a namespace, only the "inner" class name
is used in the location. If you want to include the namespace, you can pass in
the `:namespace` option with the desired separator as the value:

```rb
plugin :pretty_location, namespace: "_"
# "blog_user/.../493g82jf23.jpg"

plugin :pretty_location, namespace: "/"
# "blog/user/.../493g82jf23.jpg"
```

By default, if there is a record present, the record `id` will is used in the location.
If you want to use a different identifier for the record, you can pass in
the `:identifier` option with the desired method/attribute name as the value:

```rb
plugin :pretty_location, identifier: "uuid"
# "user/aa357797-5845-451b-8662-08eecdc9f762/profile_picture/493g82jf23.jpg"

plugin :pretty_location, identifier: :email
# "user/foo@bar.com/profile_picture/493g82jf23.jpg"
```

By default, the class name will be only downcased. We can also have the class
name underscored with the `:class_underscore` option:

```ruby
plugin :pretty_location
# "blogpost/aa357797-5845-451b-8662-08eecdc9f762/image/493g82jf23.jpg"

plugin :pretty_location, class_underscore: :true
# "blog_post/aa357797-5845-451b-8662-08eecdc9f762/image/493g82jf23.jpg"
```

For a more custom identifier logic, you can overwrite the method
`#generate_location` and call `#pretty_location` with the identifier you have
calculated.

```rb
def generate_location(io, record: nil, **context)
  identifier = record.email if record.is_a?(User)
  pretty_location(io, record: record, identifier: identifier, **context)
end
```

[pretty_location]: https://github.com/shrinerb/shrine/blob/master/lib/shrine/plugins/pretty_location.rb
