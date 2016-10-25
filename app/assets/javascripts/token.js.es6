let oauth = null;
let token = null;
let tokenExpiresAt = null;
const headers = {
    Accept: 'application/json',
};

const pathArr = window.location.href.split('/');
const url = `${pathArr[0]}//${pathArr[2]}`;

function setupOAuth(data) {
    if (data) {
	oauth = data;
	// refresh the token a bit earlier to avoid 403 responses
	tokenExpiresAt = new Date((oauth['expires_at'] - 120) * 1000);
	token = oauth['access_token'];
	if (token && token.length > 0) {
	    headers.Authorization = `Bearer ${token}`;
	}
    }
}

function checkToken() {
    if (oauth == null) setupOAuth(gon.global.oauth);
    if (tokenExpiresAt != null && tokenExpiresAt < new Date()) {
	console.log('access token expired');
	tokenExpiresAt = null;
	fetch(`${url}/oauth/token?grant_type=refresh_token&refresh_token=${oauth['refresh_token']}`, {
		method: 'post',
		    headers: {
		    'Accept': 'application/json',
		    'Content-Type': 'x-www-form-urlencoded'
		}
	    })
	    .then(function (response) {
		response.json().then(setupOAuth)
	    })
	    .catch (function (error) {
		console.log('Refresh of access-token failed - reload page:',
			    error);
		// reload the page and let the server handle the oauth bits
		location.reload();
	    });
    }
}
