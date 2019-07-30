# oauth2 via curl

#### login via password grant flow
```bash
curl -X POST https://app.buzzn.net/oauth/token -d 'grant_type=password&username=ffaerber@gmail.com&password=xxxxxxxx&scope=full'
```

### get current user
```bash
curl -H "Authorization: Bearer 694b92807b02e5b69026e74afd8015fc94a96e0802a92f74e56e188a408f291e" https://app.buzzn.net/api/v1/users/me
```

### get login token info
```bash
curl -H "Authorization: Bearer 179ba33b239314fc5121b0f5e6c522f3e067403ee8d8f6541b1e114778371f31" https://app.buzzn.net/oauth/token/info
```

### refresh expired token
```bash
curl -F grant_type=refresh_token -F refresh_token=0231fe0325bb11cc7d0c3b5b03c5beb7653bba1db0ffc4147bdb6d6f343d8bdc -X POST https://app.buzzn.net/oauth/token
```

### revoke token
```bash
curl -F token=df909e0106ec0434f3ccf014b8c91b4f70bff78464d64359d17b17c8dd6dc1f3 -H "Authorization: Bearer df909e0106ec0434f3ccf014b8c91b4f70bff78464d64359d17b17c8dd6dc1f3" -X POST https://app.buzzn.net/oauth/revoke
```


# oauth2 via Ruby

#### access-token via auhorization code grant flow
```ruby
#https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
app = Doorkeeper::Application.last
client_redirect_url = 'urn:ietf:wg:oauth:2.0:oob' # this works only in development
client = OAuth2::Client.new(app.uid, app.secret, site: "http://localhost:3000")
client.auth_code.authorize_url(scope: app.scopes, redirect_uri: client_redirect_url, state:'my_csrf_token')
```
> copy this url into your browser and then copy the access-code to

```ruby
code = 'copied from the browser'
token = client.auth_code.get_token(code, redirect_uri: client_redirect_url)
access_token = token.token
```
#### access-token via password grant flow
```ruby
app = Doorkeeper::Application.last
client = OAuth2::Client.new(app.uid, nil, site: "http://localhost:3000")
token = client.password.get_token('me@example.com', 'sekret', scope: app.scopes)
access_token = token.token
```

#### access-token via client credentials grant flow
```ruby
app = Doorkeeper::Application.last
client = OAuth2::Client.new(app.uid, app.secret, site: "http://localhost:3000")
token = client.client_credentials.get_token
```

#### access-token via implicit grant flow
```ruby
app = Doorkeeper::Application.last
client_redirect_url = 'urn:ietf:wg:oauth:2.0:oob'
client = OAuth2::Client.new(app.uid, nil, site: "http://localhost:3000")
client.implicit.authorize_url(scope: app.scopes, redirect_uri: client_redirect_url)
```

copy this url into your browser and receive the access-token json

see also: http://technotes.iangreenleaf.com/posts/closing-a-nasty-security-hole-in-oauth.html

###### notes:
* not clear who is the resource_owner in the client credential flow
* all tokens have an expires_in field set
