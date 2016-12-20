# frozen-string-literal: true

# adapted from https://github.com/jeremyevans/roda/blob/master/lib/roda/plugins/caching.rb
module Buzzn
  module Grape
    # The caching plugin adds methods related to HTTP caching.
    #
    # For proper caching, you should use either the +last_modified+ or
    # +etag+ request methods.  
    #
    #   get 'albums/:id' do
    #     album = Album.find(params[:id])
    #     last_modified @album.updated_at
    #     album
    #   end
    #
    #   # or
    #
    #   get 'albums/:d' do |album_id|
    #     album = Album.find(params[:id])
    #     etag album.sha1
    #     album
    #   end
    #
    # Both +last_modified+ or +etag+ will immediately halt processing
    # if there have been no modifications since the last time the
    # client requested the resource, assuming the client uses the
    # appropriate HTTP 1.1 request headers.
    #
    # This plugin also includes the +cache_control+ and +expires+
    # response methods.  The +cache_control+ method sets the
    # Cache-Control header using the given hash:
    #
    #   cache_control :public, :max_age=>60
    #   # Cache-Control: public, max-age=60
    # 
    # The +expires+ method is similar, but in addition
    # to setting the HTTP 1.1 Cache-Control header, it also sets
    # the HTTP 1.0 Expires header:
    #
    #   expires 60, :public
    #   # Cache-Control: public, max-age=60
    #   # Expires: Mon, 29 Sep 2014 21:25:47 GMT
    #
    # The implementation was originally taken from
    # https://github.com/jeremyevans/roda/blob/master/lib/roda/plugins/caching.rb
    # which took it from Sinatra, all are released under the MIT License:
    #
    # Copyright (c) 2007, 2008, 2009 Blake Mizerany
    # Copyright (c) 2010, 2011, 2012, 2013, 2014 Konstantin Haase
    # Copyright (c) 2014-2016 Jeremy Evans
    #
    # Permission is hereby granted, free of charge, to any person
    # obtaining a copy of this software and associated documentation
    # files (the "Software"), to deal in the Software without
    # restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the
    # Software is furnished to do so, subject to the following
    # conditions:
    # 
    # The above copyright notice and this permission notice shall be
    # included in all copies or substantial portions of the Software.
    # 
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    # OTHER DEALINGS IN THE SOFTWARE.
    module Caching
      OPTS = {}.freeze

      def self.included(object)
        object.send :include, RequestHelpers
        object.send :include, ResponseHelpers
        object.send :include, ConvenientHelpers
      end
      
      module RequestHelpers
        LAST_MODIFIED = 'Last-Modified'.freeze
        HTTP_IF_NONE_MATCH = 'HTTP_IF_NONE_MATCH'.freeze
        HTTP_IF_MATCH = 'HTTP_IF_MATCH'.freeze
        HTTP_IF_MODIFIED_SINCE = 'HTTP_IF_MODIFIED_SINCE'.freeze
        HTTP_IF_UNMODIFIED_SINCE = 'HTTP_IF_UNMODIFIED_SINCE'.freeze
        ETAG = 'ETag'.freeze
        STAR = '*'.freeze

        # Set the last modified time of the resource using the Last-Modified header.
        # The +time+ argument should be a Time instance.
        #
        # If the current request includes an If-Modified-Since header that is
        # equal or later than the time specified, immediately returns a response
        # with a 304 status.
        #
        # If the current request includes an If-Unmodified-Since header that is
        # before than the time specified, immediately returns a response
        # with a 412 status.
        def last_modified(time)
          return unless time
          header LAST_MODIFIED, time.httpdate
          return if env[HTTP_IF_NONE_MATCH]

          if (!status || status == 200) && (ims = time_from_header(env[HTTP_IF_MODIFIED_SINCE])) && ims >= time.to_i
            error! :not_modified, 304
          end

          if (!status || (status >= 200 && status < 300) || status == 412) && (ius = time_from_header(env[HTTP_IF_UNMODIFIED_SINCE])) && ius < time.to_i
            error! :precondition_failed, 412
          end
        end

        # Set the response entity tag using the ETag header.
        #
        # The +value+ argument is an identifier that uniquely
        # identifies the current version of the resource.
        # Options:
        # :weak :: Use a weak cache validator (a strong cache validator is the default)
        # :new_resource :: Whether this etag should match an etag of * (true for POST, false otherwise)
        #
        # When the current request includes an If-None-Match header with a
        # matching etag, immediately returns a response with a 304 or 412 status,
        # depending on the request method.
        #
        # When the current request includes an If-Match header with a
        # etag that doesn't match, immediately returns a response with a 412 status.
        def etag(value, opts=OPTS)
          # Before touching this code, please double check RFC 2616 14.24 and 14.26.
          weak = opts[:weak]
          new_resource = opts.fetch(:new_resource){request.request_method =~ /\APOST\z/i}

          header ETAG, etag = "#{'W/' if weak}\"#{value}\""

          if (!status || (status >= 200 && status < 300) || status == 304)
            if etag_matches?(env[HTTP_IF_NONE_MATCH], etag, new_resource)
              if request.request_method =~ /\AGET|HEAD|OPTIONS|TRACE\z/i
                error! :not_modified, 304
              else
                error! :precondition_failed, 412
              end
            end

            if ifm = env[HTTP_IF_MATCH]
              unless etag_matches?(ifm, etag, new_resource)
                error! :precondition_failed, 412
              end
            end
          end
        end

        private

        # Helper method checking if a ETag value list includes the current ETag.
        def etag_matches?(list, etag, new_resource)
          return unless list
          return !new_resource if list == STAR
          list.to_s.split(/\s*,\s*/).include?(etag)
        end

        # Helper method parsing a time value from an HTTP header, returning the
        # time as an integer.
        def time_from_header(t)
          Time.httpdate(t).to_i if t
        rescue ArgumentError
        end
      end

      module ResponseHelpers
        UNDERSCORE = '_'.freeze
        DASH = '-'.freeze
        COMMA = ', '.freeze
        CACHE_CONTROL = 'Cache-Control'.freeze
        EXPIRES = 'Expires'.freeze

        # Specify response freshness policy for using the Cache-Control header.
        # Options can can any non-value directives (:public, :private, :no_cache,
        # :no_store, :must_revalidate, :proxy_revalidate), with true as the value.
        # Options can also contain value directives (:max_age, :s_maxage).
        #
        #   response.cache_control :public=>true, :max_age => 60
        #   # => Cache-Control: public, max-age=60
        #
        # See RFC 2616 / 14.9 for more on standard cache control directives:
        # http://tools.ietf.org/html/rfc2616#section-14.9.1
        def cache_control(*opts)
          values = []
          opts.each do |o|
            case o
            when Hash
              o.each do |k, v|
                next unless v
                k = k.to_s.tr(UNDERSCORE, DASH)
                values << (v == true ? k : "#{k}=#{v}")
              end
            else
              values << o.to_s.tr(UNDERSCORE, DASH)
            end
          end

          header CACHE_CONTROL, values.join(COMMA) unless values.empty?
        end

        # Set Cache-Control header with the max_age given.  max_age should
        # be an integer number of seconds that the current request should be
        # cached for.  Also sets the Expires header, useful if you have
        # HTTP 1.0 clients (Cache-Control is an HTTP 1.1 header).
        def expires(max_age, *opts)
          cache_control(*(opts + [{:max_age=>max_age}]))
          header EXPIRES, (Time.current + max_age).httpdate
        end
      end

      module ConvenientHelpers
        PRAGMA = 'Pragma'.freeze

        # Uses the last modified timestamp for last-modified header
        # as well for the ETag. Takes the same options as the etag
        # method.
        #
        # Last-Modified: Mon, 03 Jan 2011 17:45:57 GMT
        # ETag: "15f0fff99ed5aae4edffdd6496d7131f"
        def conditionals(resource, opts=OPTS)
          if resource && resource.respond_to?(:updated_at)
            updated = resource.updated_at
          elsif resource.respond_to? :to_f
            updated = resource
          end
          if updated
            last_modified(updated)
            etag(Digest::SHA256.hexdigest(updated.to_f.to_s), opts)
          end
        end

        # Public resource which uses the geven last modified tiemstamp
        # for the conditional headers and sets the cache-control and
        # expires headers for the given max age. max age of 0 will
        # set the must-revalidate directive on cache-control.
        #
        # Cache-Control:public, max-age=86400, :must_revalidate
        # Expires: Mon, 25 Jun 2012 21:31:12 GMT
        # Last-Modified: Mon, 03 Jan 2011 17:45:57 GMT
        # ETag: "15f0fff99ed5aae4edffdd6496d7131f"
        def public(resource_or_date = nil, max_age = 86400)
          conditionals(resource_or_date)
          expires(max_age.to_i, :public, :must_revalidate)
        end

        # Private resource which uses the geven last modified tiemstamp
        # for the conditional headers and sets the cache-control and
        # expires headers for the given max age. max age of 0 will
        # set the must-revalidate directive on cache-control. I.e.
        # only the browser can cache or store the resource, all
        # intermediate proxies can not cache the data.
        #
        # Cache-Control:private, max-age=0, must-revalidate
        # Expires: Mon, 25 Jun 2012 21:31:12 GMT
        # Last-Modified: Mon, 03 Jan 2011 17:45:57 GMT
        # ETag: "15f0fff99ed5aae4edffdd6496d7131f"
        def private(resource_or_date = nil, max_age = 0)
           conditionals(resource_or_date)
           expires(max_age.to_i, :private, :must_revalidate)
        end

        # No browser nor proxies are allowed to cache or store the data
        # of this resource.
        #
        # Cache-Control:private, max-age=0, no-store, no-cache, must-revalidate
        # Pragma: no-cache
        # Expires: Fri, 01 Jan 1990 00:00:00 GMT
        def confidential
          header PRAGMA, 'no-cache'
          expires(0, :private, :no_store, :no_cache, :must_revalidate)
        end
      end
    end
  end
end
