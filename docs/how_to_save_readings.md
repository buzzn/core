***********************************************************
***       HOW TO WRITE READINGS VIA BUZZN API        ******
***********************************************************


buzzn API available at: https://app.buzzn.net/api



1. Get an access token for a registered user:
*********************************************
--------------------------------------------------------------------------------------------------------------------------------
curl -X POST https://app.buzzn.net/oauth/token -d 'grant_type=password&username=email@example.com&password=xxxxxxxx&scope=full'
--------------------------------------------------------------------------------------------------------------------------------

Please replace 'email@example.com' and 'xxxxxxxx' with the email and password of your account.

The response should look like this:
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{"access_token":"85d134acf33eed098eff8909abb33345761b06","token_type":"bearer","expires_in":7200,"refresh_token":"f4ade9c8198fa457aed22091f78e3ae77d61","scope":"full","created_at":1476265600}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


2. Create a new meter for which you want to write energy-/power data
********************************************************************
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header 'Authorization: 85d134acf33eed098eff8909abb33345761b06' -d 'manufacturer_name=easymeter&manufacturer_product_name=q3d&manufacturer_product_serialnumber=1010101010&smart=true' 'https://app.buzzn.net/api/v1/meters'
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Make sure you use the access_token from step 1 and replace 'easymeter', 'q3d' and '1010101010' with the names and numbers of your meter.

*a*: 	If your meter got created your response body should look like this (with a 201 status code):
	--------------------------------------------------------------------------------------------------------------------------------
	{
	  "data": {
	    "id": "9a54ec4c-dd1e-454b-a07e-2de64e034741",
	    "type": "meters",
	    "links": {
	      "self": "https://app.buzzn.net/api/v1/meters/9a54ec4c-dd1e-454b-a07e-2de64e034741"
	    },
	    "attributes": {
	      "manufacturer-name": "easymeter",
	      "manufacturer-product-name": "q3d",
	      "manufacturer-product-serialnumber": "1010101010",
	      "smart": true,
	      "online": false
	    },
	    "relationships": {
	      "metering-points": {
		"links": {
		  "self": "https://app.buzzn.net/api/v1/meters/9a54ec4c-dd1e-454b-a07e-2de64e034741/relationships/metering-points",
		  "related": "https://app.buzzn.net/api/v1/meters/9a54ec4c-dd1e-454b-a07e-2de64e034741/metering-points"
		}
	      }
	    }
	  }
	}
	--------------------------------------------------------------------------------------------------------------------------------

	Make sure to save the id for future reference!

*b*: 	If your meter already exists your response body may look like this (with a 422 status code):
	------------------------------------------------------------------------
	{
	  "errors": [
	    {
	      "source": {
		"pointer": "/data/attributes/manufacturer_product_serialnumber"
	      },
	      "title": "Invalid Attribute",
	      "detail": "manufacturer_product_serialnumber ist bereits vergeben"
	    }
	  ]
	}
	------------------------------------------------------------------------

	In this case you should use the id of the meter that you have already created. 

	NOTE:

	To get all your meters please use these endpoints:
	------------------------------
	get /api/v1/users/me
	get /api/v1/users/{id}/meters 
	------------------------------
	Replace {id} with the user_id you got from the first call.


3. Create a new metering_point that belongs to your meter
*********************************************************

Only perform this step if your meter is not connected to a metering_point yet!

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header 'Authorization: 85d134acf33eed098eff8909abb33345761b06' -d 'name=Wohnung&mode=in&readable=world&meter_id=9a54ec4c-dd1e-454b-a07e-2de64e034741' 'https://app.buzzn.net/api/v1/metering-points'
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You can replace 'Wohnung' with any name you want.

Your response body should look like this (with a 201 status code):
------------------------------------------------------------------------------------------------------------------------------
{
  "data": {
    "id": "9b27e9f2-a372-437f-b01a-0101f80f6c6e",
    "type": "metering-points",
    "links": {
      "self": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e"
    },
    "attributes": {
      "uid": null,
      "name": "Wohnung",
      "mode": "in",
      "meter-id": "9a54ec4c-dd1e-454b-a07e-2de64e034741",
      "readable": "world"
    },
    "relationships": {
      "devices": {
        "links": {
          "self": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e/relationships/devices",
          "related": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e/devices"
        }
      },
      "users": {
        "links": {
          "self": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e/relationships/users",
          "related": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e/users"
        }
      },
      "address": {
        "links": {
          "self": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e/relationships/address",
          "related": "https://app.buzzn.net/api/v1/metering-points/9b27e9f2-a372-437f-b01a-0101f80f6c6e/address"
        }
      }
    }
  }
}
------------------------------------------------------------------------------------------------------------------------------


4. Write energy-/power data
***************************
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
curl -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header 'Authorization: 85d134acf33eed098eff8909abb33345761b06' -d 'meter_id=9a54ec4c-dd1e-454b-a07e-2de64e034741&timestamp=2016-10-12%2014%3A53%3A52%20%2B0200&energy_a_milliwatt_hour=20000&power_a_milliwatt=56784' 'https://app.buzzn.net/api/v1/readings'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Keep in mind thar energy_a_milliwatt_hour and energy_b_milliwatt_hour are measurements, while power_a_milliwatt and power_b_milliwatt is the power that is consumed since the last reading. 

Your response body should look like this (with a status code of 201):

--------------------------------------------------------------------------------
{
  "data": {
    "id": "57fe341466926c2f78000cf0",
    "type": "readings",
    "links": {
      "self": "https://app.buzzn.net/api/v1/readings/57fe341466926c2f78000cf0"
    },
    "attributes": {
      "energy-a-milliwatt-hour": 20000,
      "energy-b-milliwatt-hour": null,
      "power-a-milliwatt": 56784,
      "power-b-milliwatt": null,
      "timestamp": "2016-10-12T14:53:52.000+02:00",
      "meter-id": "9a54ec4c-dd1e-454b-a07e-2de64e034741"
    }
  }
}
--------------------------------------------------------------------------------



NOTES:

If your access_token expires please use your refresh_token to get a new one:

---------------------------------------------------------------------------------------------------------------------------------
curl -F grant_type=refresh_token -F refresh_token=f4ade9c8198fa457aed22091f78e3ae77d61 -X POST https://app.buzzn.net/oauth/token
---------------------------------------------------------------------------------------------------------------------------------

Make sure to add the refresh_token that you received in step 1.








