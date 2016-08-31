
# access-token via auhorization code grant flow
    #https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
    app = Doorkeeper::Application.last
    # this works only in development
    client_redirect_url = 'urn:ietf:wg:oauth:2.0:oob'
    client = OAuth2::Client.new(app.uid, app.secret, site: "http://localhost:3000")
    client.auth_code.authorize_url(scope: app.scopes, redirect_uri: client_redirect_url)

copy this url into your browser and then copy the access-code to

    code = 'copied from the browser' 
    token = client.auth_code.get_token(code, redirect_uri: client_redirect_url)
    access_token = token.token

# access-token via password grant flow
    app = Doorkeeper::Application.last
    client = OAuth2::Client.new(app.uid, nil, site: "http://localhost:3000")
    token = client.password.get_token('me@example.com', 'sekret', scope: app.scopes)
    access_token = token.token


# access-token via client credentials grant flow
    app = Doorkeeper::Application.last
    client = OAuth2::Client.new(app.uid, app.secret, site: "http://localhost:3000")
    token = client.client_credentials.get_token

# access-token via implicit grant flow
   app = Doorkeeper::Application.last
   client_redirect_url = 'urn:ietf:wg:oauth:2.0:oob'
   client = OAuth2::Client.new(app.uid, nil, site: "http://localhost:3000")
   client.implicit.authorize_url(scope: app.scopes, redirect_uri: client_redirect_url)

copy this url into your browser and receive the access-token json

see also: http://technotes.iangreenleaf.com/posts/closing-a-nasty-security-hole-in-oauth.html

notes:
* not clear who is the resource_owner in the client credential flow
* all tokens have an expires_in field set


    
