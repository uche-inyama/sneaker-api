---
title: Validation
---

The [`validation`][validation] plugin provides a framework for validating
attached files. For some useful validators, see the
[`validation_helpers`][validation_helpers] plugin.

```rb
plugin :validation
```

## Usage

The `Attacher.validate` method is used to register a validation block, which
is called on attachment:

```rb
class VideoUploader < Shrine
  Attacher.validate do
    if file.duration > 5*60*60
      errors << "duration must not be longer than 5 hours"
    end
  end
end
```
```rb
attacher.assign(file)
attacher.errors #=> ["duration must not be longer than 5 hours"]
```

The validation block is executed in context of a `Shrine::Attacher` instance:

```rb
class VideoUploader < Shrine
  Attacher.validate do
    self    #=> #<Shrine::Attacher>

    file    #=> #<Shrine::UploadedFile>
    record  #=> #<Movie>
    name    #=> :video
    context #=> { ... }
  end
end
```

## Inheritance

If you're subclassing an uploader that has validations defined, you can call
those validations via `super()`:

```rb
class ApplicationUploader < Shrine
  Attacher.validate { validate_max_size 5.megabytes }
end
```
```rb
class ImageUploader < ApplicationUploader
  Attacher.validate do
    super() # empty parentheses are required
    validate_mime_type %w[image/jpeg image/png image/webp]
  end
end
```

## Validation options

You can pass options to the validator via the `:validate` option:

```rb
attacher.assign(file, validate: { foo: "bar" })
```
```rb
class MyUploader < Shrine
  Attacher.validate do |**options|
    options #=> { foo: "bar" }
  end
end
```

You can also skip validation by passing `validate: false`:

```rb
attacher.assign(file, validate: false) # skips validation
```

## Manual validation

You can also run validation manually via `Attacher#validate`:

```rb
attacher.set(uploaded_file) # doesn't trigger validation
attacher.validate           # runs validation
```

[validation]: https://github.com/shrinerb/shrine/blob/master/lib/shrine/plugins/validation.rb
[validation_helpers]: https://shrinerb.com/docs/plugins/validation_helpers
