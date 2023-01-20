---
title: Derivation Endpoint
---

The [`derivation_endpoint`][derivation_endpoint] plugin provides a Rack app for
dynamically processing uploaded files on request. This allows you to create
URLs to files that might not have been generated yet, and have the endpoint
process them on-the-fly.

## Quick start

We first load the plugin, providing a secret key and a path prefix to where the
endpoint will be mounted:

```rb
class ImageUploader < Shrine
  plugin :derivation_endpoint,
    secret_key: "<YOUR SECRET KEY>",
    prefix:     "derivations/image"
end
```

We can then mount the derivation endpoint for our uploader into our app's
router on the path prefix we specified:

```rb
# config/routes.rb (Rails)
Rails.application.routes.draw do
  mount ImageUploader.derivation_endpoint => "derivations/image"
end
```

Next we can define a "derivation" block for the type of processing we want to
apply to an attached file. For example, we can generate image thumbnails using
the [ImageProcessing] gem:

```rb
gem "image_processing", "~> 1.8"
```
```rb
require "image_processing/mini_magick"

class ImageUploader < Shrine
  # ...
  derivation :thumbnail do |file, width, height|
    ImageProcessing::MiniMagick
      .source(file)
      .resize_to_limit!(width.to_i, height.to_i)
  end
end
```

Now we can generate "derivation" URLs from attached files, which on request
will call the derivation block we defined.

```rb
photo.image.derivation_url(:thumbnail, 600, 400)
#=> "/derivations/image/thumbnail/600/400/eyJpZCI6ImZvbyIsInN0b3JhZ2UiOiJzdG9yZSJ9?signature=..."
```

In this example, `photo` is an instance of a `Photo` model which has an `image`
attachment. The URL will render a `600x400` thumbnail of the original image.

## How it works

The `#derivation_url` method is defined on `Shrine::UploadedFile` objects. It
generates an URL consisting of the configured [path prefix](#prefix),
derivation name and arguments, serialized uploaded file, and an URL signature
generated using the configured secret key:

```
/  derivations/image  /  thumbnail  /  600/400  /  eyJmZvbyIb3JhZ2UiOiJzdG9yZSJ9  ?  signature=...
  └──── prefix ─────┘  └── name ──┘  └─ args ─┘  └─── serialized source file ───┘
```

When the derivation URL is requested, the derivation endpoint will first verify
the signature included in query params, and proceed only if it matches the
calculated signature. This ensures that only the server can generate valid
derivation URLs, preventing potential DoS attacks.

The derivation endpoint then extracts the source file data, derivation name and
arguments from the request URL, and calls the corresponding derivation block,
passing the downloaded source file and derivation arguments. The derivation
block is evaluated within the context of a
[`Shrine::Derivation`](#derivation-api) instance.

```rb
derivation :thumbnail do |file, arg1, arg2, ...|
  self #=> #<Shrine::Derivation>

  file #=> #<Tempfile:...> (source file downloaded to disk)
  arg1 #=> "600" (first derivation argument in #derivation_url)
  arg2 #=> "400" (second derivation argument in #derivation_url)

  # ... do processing ...

  # return result as a File or Tempfile object
end
```

The derivation block is expected to return the processed file as a `File` or
`Tempfile` object. The resulting file is then rendered in the HTTP response.

### Performance

By default, the processed file returned by the derivation block is not cached
anywhere. This means that repeated requests to the same derivation URL will
execute the derivation block each time, which can put a lot of load on your
application.

For this reason it's highly recommended to put a **CDN or other HTTP cache** in
front of your application. If you've configured a CDN, you can set the CDN host
at the plugin level, and it will be used for all derivation URLs:

```rb
plugin :derivation_endpoint, host: "https://your-dist-url.cloudfront.net"
```

Additionally, you can have the endpoint cache derivatives to a storage. With
this setup, the generated derivative will be uploaded to the storage on initial
request, and then on subsequent requests the derivative will be served directly
from the storage.

```rb
plugin :derivation_endpoint, upload: true
```

If you want to avoid having the endpoint directly serve the generated
derivatives, you can have the derivation response redirect to the uploaded
derivative on the storage service.

```rb
plugin :derivation_endpoint, upload: true, upload_redirect: true
```

For more details, see the [Uploading](#uploading) section.

## Derivation response

Mounting the derivation endpoint into the app's router is the easiest way to
handle derivation requests, as routing and setting the response is done
automatically.

```rb
# config/routes.rb
Rails.application.routes.draw do
  mount ImageUploader.derivation_endpoint => "derivations/image"
end
```

However, this approach can also be limiting if one wants to perform additional
operations around derivation requests, such as authentication and
authorization.

Instead of mounting the endpoint into the router, you can also call the
derivation endpoint from a controller. In this case the endpoint needs to
receive the Rack env hash, so that it can infer derivation parameters from the
request URL. The return value is a 3-element array, containing the status,
headers, and body that should be returned in the HTTP response:

```rb
# config/routes.rb
Rails.application.routes.draw do
  get "/derivations/image/*rest" => "derivations#image"
end
```
```rb
# app/controllers/derivations_controller.rb
class DerivationsController < ApplicationController
  def image
    # ... we can perform authentication here ...

    set_rack_response ImageUploader.derivation_response(request.env)
  end

  private

  def set_rack_response((status, headers, body))
    self.status = status
    self.headers.merge!(headers)
    self.response_body = body
  end
end
```

For even more control, you can generate derivation responses in custom routes.
Once you retrieve the `Shrine::UploadedFile` object, you can call
`#derivation_response` directly on it, passing the derivation name and
arguments, as well as the Rack env hash.

```rb
# config/routes.rb
Rails.application.routes.draw do
  resources :photos do
    member do
      get "thumbnail" # for example
    end
  end
end
```
```rb
# app/controllers/photos_controller.rb
class PhotosController < ApplicationController
  def thumbnail
    # we can perform authorization here
    photo = Photo.find(params[:id])
    image = photo.image

    set_rack_response image.derivation_response(:thumbnail, 300, 300, env: request.env)
  end

  private

  def set_rack_response((status, headers, body))
    self.status = status
    self.headers.merge!(headers)
    self.response_body = body
  end
end
```

`Shrine.derivation_endpoint`, `Shrine.derivation_response`, and
`UploadedFile#derivation_response` methods all accept additional options, which
will override options set on the plugin level.

```rb
ImageUploader.derivation_endpoint(disposition: "attachment")
# or
ImageUploader.derivation_response(env, disposition: "attachment")
# or
uploaded_file.derivation_response(:thumbnail, env: env, disposition: "attachment")
```

## Dynamic settings

For most options passed to `plugin :derivation_endpoint`,
`Shrine.derivation_endpoint`, `Shrine.derivation_response`, or
`Shrine::UploadedFile#derivation_response`, the value can also be a block that
returns a dynamic result. The block will be evaluated within the context of a
[`Shrine::Derivation`](#derivation-api) instance, allowing you to access
information about the current derivation:

```rb
plugin :derivation_endpoint, disposition: -> {
  self   #=> #<Shrine::Derivation>

  name   #=> :thumbnail
  args   #=> ["500", "400"]
  source #=> #<Shrine::UploadedFile>

  # ...
}
```

For example, we can use it to specify that thumbnails should be rendered inline
in the browser, while other derivatives will be force downloaded.

```rb
plugin :derivation_endpoint, disposition: -> {
  name == :thumbnail ? "inline" : "attachment"
}
```

## Host

Derivation URLs are relative by default. To generate absolute URLs, you can
pass the `:host` option:

```rb
plugin :derivation_endpoint, host: "https://example.com"
```

Now the generated URLs will include the specified URL host:

```rb
uploaded_file.derivation_url(:thumbnail)
#=> "https://example.com/.../thumbnail/eyJpZCI6ImZvbyIsInN?signature=..."
```

You can also pass `:host` per URL:

```rb
uploaded_file.derivation_url(:thumbnail, host: "https://example.com")
#=> "https://example.com/.../thumbnail/eyJpZCI6ImZvbyIsInN?signature=..."
```

## Prefix

If you're mounting the derivation endpoint under a path prefix, the derivation
URLs will need to include that path prefix. This can be configured with the
`:prefix` option:

```rb
plugin :derivation_endpoint, prefix: "transformations/image"
```

Now generated URLs will include the specified path prefix:

```rb
uploaded_file.derivation_url(:thumbnail)
#=> ".../transformations/image/thumbnail/eyJpZCI6ImZvbyIsInN?signature=..."
```

You can also pass `:prefix` per URL:

```rb
uploaded_file.derivation_url(:thumbnail, prefix: "transformations/image")
#=> ".../transformations/image/thumbnail/eyJpZCI6ImZvbyIsInN?signature=..."
```

## Expiration

By default derivation URLs are valid indefinitely. If you want URLs to expire
after a certain amount of time, you can set the `:expires_in` option:

```rb
plugin :derivation_endpoint, expires_in: 90
```

Now any URL will stop being valid 90 seconds after it was generated:

```rb
uploaded_file.derivation_url(:thumbnail)
#=> ".../thumbnail/eyJpZCI6ImZvbyIsInN?expires_at=1547843568&signature=..."
```

You can also pass `:expires_in` per URL:

```rb
uploaded_file.derivation_url(:thumbnail, expires_in: 90)
#=> ".../thumbnail/eyJpZCI6ImZvbyIsInN?expires_at=1547843568&signature=..."
```

## Response headers

### Content Type

The derivation response includes the [`Content-Type`] header. By default
default its value will be inferred from the file extension of the generated
derivative (using `Rack::Mime`). This can be overriden with the `:type` option:

```rb
plugin :derivation_endpoint, type: -> { "image/webp" if name == :webp }
```

The above will set `Content-Type` response header value to `image/webp` for
`:webp` derivatives, while for others it will be inferred from the file
extension if possible.

You can also set `:type` per URL:

```rb
uploaded_file.derivation_url(:webp, type: "image/webp")
#=> ".../webp/eyJpZCI6ImZvbyIsInN?type=image%2Fwebp&signature=..."
```

### Content Disposition

The derivation response includes the [`Content-Disposition`] header. By default
the disposition is set to `inline`, with download filename generated from
derivation name, arguments and source file id. These values can be changed with
the `:disposition` and `:filename` options:

```rb
plugin :derivation_endpoint,
  disposition: -> { name == :thumbnail ? "inline" : "attachment" },
  filename:    -> { [name, *args].join("-") }
```

With the above settings, visiting a thumbnail URL will render the image in the
browser, while other derivatives will be treated as an attachment and be
downloaded.

The `:filename` and `:disposition` options can also be set per URL:

```rb
uploaded_file.derivation_url(:pdf, disposition: "attachment", filename: "custom-filename")
#=> ".../thumbnail/eyJpZCI6ImZvbyIsInN?disposition=attachment&filename=custom-filename&signature=..."
```

### Cache Control

The endpoint uses the [`Cache-Control`] response header to tell clients
(browsers, CDNs, HTTP caches) how long they can cache derivation responses. The
default cache duration is 1 year from the initial request, or if
[`:expires_in`](#expiration) is used it's the time until the URL expires. The
header value can be changed with the `:cache_control` option:

```rb
plugin :derivation_endpoint, cache_control: "public, max-age=#{7*24*60*60}" # 7 weeks
```

Note that `Cache-Control` is added to response headers only when using
`Shrine.derivation_endpoint` or `Shrine.derivation_response`, it's not added
when using `Shrine::UploadedFile#derivation_response`.

## Uploading

By default the generated derivatives aren't saved anywhere, which means that
repeated requests to the same derivation URL will call the derivation block
each time. If you don't want to rely on solely on your HTTP cache, you can
enable the `:upload` option, which will make derivatives automatically cached
on the Shrine storage:

```rb
plugin :derivation_endpoint, upload: true
```

Now whenever a derivation is requested, the endpoint will first check whether
the derivative already exists on the storage. If it doesn't exist, it will
fetch the original uploaded file, call the derivation block, upload the
derivative to the storage, and serve the derivative. If the derivative does
exist on checking, the endpoint will download the derivative and serve it.

### Upload location

The default upload location for derivatives is `<source id>/<name>-<args>`.
This can be changed with the `:upload_location` option:

```rb
plugin :derivation_endpoint, upload: true, upload_location: -> {
  # e.g. "derivatives/9a7d1bfdad24a76f9cfaff137fe1b5c7/thumbnail-1000-800"
  ["derivatives", File.basename(source.id, ".*"), [name, *args].join("-")].join("/")
}
```

Since the default upload location won't have any file extension, the derivation
response won't know the appropriate `Content-Type` header value to set, and the
generic `application/octet-stream` will be used. It's recommended to use the
[`:type`](#content-type) option to set the appropriate `Content-Type` value.

### Upload storage

The target storage used is the same as for the source uploaded file. The
`:upload_storage` option can be used to specify a different Shrine storage:

```rb
plugin :derivation_endpoint, upload: true,
                             upload_storage: :thumbnail_storage
```

### Upload options

Additional storage-specific upload options can be passed via `:upload_options`:

```rb
plugin :derivation_endpoint, upload: true,
                             upload_options: { acl: "public-read" }
```

### Upload open options

Additional storage-specific download options for the uploaded derivation result
can be passed via `:upload_open_options`:

```rb
plugin :derivation_endpoint, upload: true,
                             upload_open_options: { response_content_encoding: "gzip" }
```

### Redirecting

If you are using remote cloud storages, you can configure the endpoint to
redirect the client to the uploaded derivative on the remote storage instead of
serving it through the endpoint (which is the default behaviour) by setting both
`:upload` and `:upload_redirect` to `true`:

```rb
plugin :derivation_endpoint, upload: true,
                             upload_redirect: true
```

Additional storage-specific URL options can be passed in for the redirect URL:

```rb
plugin :derivation_endpoint, upload: true,
                             upload_redirect: true,
                             upload_redirect_url_options: { public: true }
```

Note that redirecting only makes sense if you're using remote storage services
such as AWS S3 or Google Cloud Storage.

### Deleting derivatives

When the original attachment is deleted, its uploaded derivatives will not be
automatically deleted, you will need to do the deletion manually. If you're
using [backgrounding], you can do this in your `DestroyJob`.

If your storage implements `#delete_prefixed`, and you're using the default
[`:upload_location`](#upload-location), you can delete the directory containing
derivatives:

```rb
class DestroyJob < ActiveJob::Base
  def perform(attacher_class, data)
    # ... destroy attached file ...

    derivatives_directory = attacher.file.id + "/"
    storage               = attacher.store.storage

    storage.delete_prefixed(derivatives_directory)
  end
end
```

Alternatively, you can delete each derivative individually:

```rb
class ImageUploader < Shrine
  DERIVATIONS = [
    [:thumbnail, 800, 800],
    [:thumbnail, 600, 400],
    [:thumbnail, 400, 300],
    ...
  ]
end
```
```rb
class DestroyJob < ActiveJob::Base
  def perform(attacher_class, data)
    # ... destroy attached file ...

    attacher.shrine_class::DERIVATIONS.each do |args|
      attacher.file.derivation(*args).delete
    end
  end
end
```

## Cache busting

The derivation endpoint response instructs browsers, CDNs and other clients to
cache the response for a long time. This saves server resources and improves
response times. However, if the derivation block is modified, the derivation
URLs will remain unchanged, which means that old cached derivatives might still
be served.

If you want to ensure derivation URLs don't point to old cached derivatives,
you can add a "version" query parameter to the URL, which will make HTTP caches
treat it as a new URL. You can do this via the `:version` option:

```rb
plugin :derivation_endpoint, version: -> { 1 if name == :thumbnail }
```

With the above settings, all `:thumbnail` derivation URLs will include
`version` in the query string:

```rb
uploaded_file.derivation_url(:thumbnail)
#=> ".../thumbnail/eyJpZCI6ImZvbyIsInN?version=1&signature=..."
```

You can also bump the `:version` per URL:

```rb
uploaded_file.derivation_url(:thumbnail, version: 1)
#=> ".../thumbnail/eyJpZCI6ImZvbyIsInN?version=1&signature=..."
```

## Accessing source file

Inside the derivation block we can access the source `UploadedFile` object via
`Shrine::Derivation#source`:

```rb
derivation :thumbnail do |file, width, height|
  source             #=> #<Shrine::UploadedFile>
  source.id          #=> "9a7d1bfdad24a76f9cfaff137fe1b5c7.jpg"
  source.storage_key #=> :store
  source.metadata    #=> {}

  # ...
end
```

By default, when using the derivation endpoint, original metadata of the source
file won't be available in the derivation block. This is because any metadata
we would want to have available would need to be serialized into the derivation
URL, which would make it longer. Instead, you can opt in for the metadata you
want to have available:

```rb
plugin :derivation_endpoint, metadata: ["filename", "mime_type"]

derivation :thumbnail do |file, width, height|
  source.metadata #=>
  # {
  #  "filename" => "nature.jpg",
  #  "mime_type" => "image/jpeg"
  # }

  source.original_filename #=> "nature.jpg"
  source.mime_type         #=> "image/jpeg"

  # ...
end
```

## Downloading

When a derivation is requested, the original uploaded file will be downloaded
to disk before the derivation block is called. If you want to pass in
additional storage-specific download options, you can do so via
`:download_options`:

```rb
plugin :derivation_endpoint, download_options: {
  sse_customer_algorithm: "AES256",
  sse_customer_key:       "secret_key",
  sse_customer_key_md5:   "secret_key_md5",
}
```

If the source file was not found, `Shrine::Derivation::SourceNotFound`
exception is raised. In a derivation response this is converted into a `404 Not
Found` response.

### Skipping download

If for whatever reason you don't want the uploaded file to be downloaded to
disk for you, you can set `:download` to `false`.

```rb
plugin :derivation_endpoint, download: false

derivation :thumbnail do |width, height| # source file is not downloaded
  # ...
end
```

One use case for this is delegating processing to a 3rd-party service:

```rb
require "down/http"

derivation :thumbnail do |width, height|
  # generate the thumbnail using ImageOptim.com
  down = Down::Http.new(method: :post)
  down.download("https://im2.io/<USERNAME>/#{width}x#{height}/#{source.url}")
end
```

## Derivation API

In addition to generating derivation responses, it's also possible to operate
with derivations on a lower level. You can access that API by calling
`UploadedFile#derivation`, which returns a `Derivation` object.

```rb
derivation = uploaded_file.derivation(:thumbnail, 500, 500)
derivation #=> #<Shrine::Derivation: @name=:thumbnail, @args=[500, 500] ...>
derivation.name   #=> :thumbnail
derivation.args   #=> [500, 500]
derivation.source #=> #<Shrine::UploadedFile>
```

When initializing the `Derivation` object you can override any plugin options:

```rb
uploaded_file.derivation(:grayscale, upload_storage: :other_storage)
```

### `#url`

`Derivation#url` method (called by `UploadedFile#derivation_url`) generates the
URL to the derivation.

```rb
derivation.url #=> "/thumbnail/500/400/eyJpZCI6ImZvbyIsInN0b3JhZ2UiOiJzdG9yZSJ9?signature=..."
```

### `#response`

`Derivation#response` method (called by `UploadedFile#derivation_response`)
generates appropriate status, headers, and body for the derivative to be
returned as an HTTP response.

```rb
status, headers, body = derivation.response
status  #=> 200
headers #=>
# {
#   "Content-Type" => "image/jpeg",
#   "Content-Length" => "12424",
#   "Content-Disposition" => "inline; filename=\"thumbnail-500-500-k9f8sdksdfk2414\"",
#   "Accept_Ranges" => "bytes"
# }
body    #=> #each object that yields derivative content
```

### `#processed`

`Derivation#processed` method returns the processed derivative. If
[`:upload`](#uploading) is enabled, it returns a `Shrine::UploadedFile` object
pointing to the derivative, processing and uploading the derivative if it
hasn't been already.

```rb
uploaded_file = derivation.processed
uploaded_file    #=> #<Shrine::UploadedFile>
uploaded_file.id #=> "bcfd0d67e4a8ec2dc9a6d7ddcf3825a1/thumbnail-500-500"
```

### `#generate`

`Derivation#generate` method calls the derivation block and returns the result.

```rb
result = derivation.generate
result #=> #<Tempfile:...>
```

Internally it will download the source uploaded file to disk and pass it to the
derivation block (unless `:download` was disabled). You can also pass in an
already downloaded source file:

```rb
derivation.generate(source_file)
```

### `#upload`

`Derivation#upload` method uploads the given file to the configured derivation
location.

```rb
uploaded_file = derivation.upload(file)
uploaded_file    #=> #<Shrine::UploadedFile>
uploaded_file.id #=> "bcfd0d67e4a8ec2dc9a6d7ddcf3825a1/thumbnail-500-500"
```

It can also be called without arguments, in which case it will generate a new
derivative and upload it.

```rb
derivation.upload # generates derivative and uploads it
```

Any additional options will be passed to the uploader.

### `#retrieve`

`Derivation#retrieve` method returns `Shrine::UploadedFile` object pointing to
the uploaded derivative if it exists. If the uploaded derivative does not
exist, `nil` is returned.

```rb
uploaded_file = derivation.retrieve
uploaded_file    #=> #<Shrine::UploadedFile>
uploaded_file.id #=> "bcfd0d67e4a8ec2dc9a6d7ddcf3825a1/thumbnail-500-500"
```

### `#opened`

`Derivation#opened` method returns opened `Shrine::UploadedFile` object pointing
to the uploaded derivative if it exists. If the uploaded derivative does not
exist, `nil` is returned.

```rb
uploaded_file = derivation.opened
uploaded_file    #=> #<Shrine::UploadedFile>
uploaded_file.id #=> "bcfd0d67e4a8ec2dc9a6d7ddcf3825a1/thumbnail-500-500"
```

### `#delete`

`Derivation#delete` method deletes the uploaded derivative file from the
storage.

```rb
derivation.delete
```

### `#option`

`Derivation#option` returns the value of the specified plugin option.

```rb
derivation.option(:upload_location)
#=> "bcfd0d67e4a8ec2dc9a6d7ddcf3825a1/thumbnail-500-500"
```

## Plugin Options

| Name                           | Description                                                                                                                           | Default                                              |
| :----------------------------- | :----------                                                                                                                           | :--------                                            |
| `:cache_control`               | Hash of directives for the `Cache-Control` response header                                                                            | `{ public: true, max_age: 365*24*60*60 }`            |
| `:disposition`                 | Whether the browser should attempt to render the derivative (`inline`) or prompt the user to download the file to disk (`attachment`) | `inline`                                             |
| `:download`                    | Whether the source uploaded file should be downloaded to disk when the derivation block is called                                     | `true`                                               |
| `:download_options`            | Additional options to pass when downloading the source uploaded file                                                                  | `{}`                                                 |
| `:expires_in`                  | Number of seconds after which the URL will not be available anymore                                                                   | `nil`                                                |
| `:filename`                    | Filename the browser will assume when the derivative is downloaded to disk                                                            | `<name>-<args>-<source id basename>`                 |
| `:host`                        | URL host to use when for URLs                                                                                                         | `nil`                                                |
| `:metadata`                    | List of metadata keys the source uploaded file should include in the derivation block                                                 | `[]`                                                 |
| `:prefix`                      | Path prefix added to the URLs                                                                                                         | `nil`                                                |
| `:secret_key`                  | Key used to sign derivation URLs in order to prevent tampering                                                                        | required                                             |
| `:type`                        | Media type returned in the `Content-Type` response header in the derivation response                                                  | determined from derivative's extension when possible |
| `:upload`                      | Whether the generated derivatives will be cached on the storage                                                                       | `false`                                              |
| `:upload_location`             | Location to which the derivatives will be uploaded on the storage                                                                     | `<source id>/<name>-<args>`                          |
| `:upload_options`              | Additional options to be passed when uploading derivatives                                                                            | `{}`                                                 |
| `:upload_open_options`         | Additional options to be passed when downloading the uploaded derivative                                                              | `{}`                                                 |
| `:upload_redirect`             | Whether the derivation response should redirect to the uploaded derivative                                                            | `false`                                              |
| `:upload_redirect_url_options` | Additional options to be passed when generating the URL for the uploaded derivative                                                   | `{}`                                                 |
| `:upload_storage`              | Storage to which the derivations will be uploaded                                                                                     | same storage as the source file                      |
| `:version`                     | Version number to append to the URL for cache busting                                                                                 | `nil`                                                |

## Instrumentation

If the `instrumentation` plugin has been loaded, the `determine_mime_type` plugin
adds instrumentation around derivation processing.

```rb
# instrumentation plugin needs to be loaded *before* derivation_endpoint
plugin :instrumentation
plugin :derivation_endpoint
```

Derivation processing will trigger a `derivation.shrine` event with the
following payload:

| Key           | Description                                     |
| :--           | :----                                           |
| `:derivation` | `Shrine::Derivation` object for this processing |
| `:uploader`   | The uploader class that sent the event          |

A default log subscriber is added as well which logs these events:

```
Derivation (492ms) – {:name=>:thumbnail, :args=>[600, 600], :uploader=>Shrine}
```

You can also use your own log subscriber:

```rb
plugin :derivation_endpoint, log_subscriber: -> (event) {
  Shrine.logger.info JSON.generate(
    name:     event.name,
    duration: event.duration,
    name:     event[:derivation].name,
    args:     event[:derivation].args,
  )
}
```
```
{"name":"derivation","duration":492,"name":"thumbnail","args":[600,600],"uploader":"Shrine"}
```

Or disable logging altogether:

```rb
plugin :derivation_endpoint, log_subscriber: nil
```

[derivation_endpoint]: https://github.com/shrinerb/shrine/blob/master/lib/shrine/plugins/derivation_endpoint.rb
[ImageProcessing]: https://github.com/janko/image_processing
[`Content-Type`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type
[`Content-Disposition`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
[backgrounding]: https://shrinerb.com/docs/plugins/backgrounding
