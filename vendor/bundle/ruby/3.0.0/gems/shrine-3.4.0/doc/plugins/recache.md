---
title: Re-cache
---

The [`recache`][recache] plugin allows you to process your attachment after
validations succeed, but before the attachment is promoted. This is useful for
example when you want to generate some versions upfront (so the user
immediately sees them) and other versions you want to generate in the promotion
phase in a background job.

```rb
plugin :recache
plugin :processing

process(:recache) do |io, context|
  # perform cheap processing
end

process(:store) do |io, context|
  # perform more expensive processing
end
```

Recaching will be automatically triggered in a "before save" callback, but if
you're using the attacher directly, you can call it manually:

```rb
attacher.recache if attacher.changed?
```

[recache]: https://github.com/shrinerb/shrine/blob/master/lib/shrine/plugins/recache.rb
