# Echo Remote Calls ✨

Welcome to the remote calls repository used by [EchoRP](https://echorp.net).

Below you can find important information on how to effectively use this remote call script.


## What are remote calls?

Similar to callbacks, remote calls allow you to communicate information between the client->server and server->client. An example is the client can request their bank amount from the server using a quick remote call. This doesn't require a crazy amount of intelligence to use. We make use of FiveM event handlers to "register" remote calls and then just execute an export, simple!

I have been using this on the live server for EchoRP and it has been working very well. It's accurate and fast, nothing more you'd really want from something as simple as this. I've tried many remote call/callback resources but they're all either broken or complex to use. If you run into any issues, make an issue and I shall assist. Likewise, with changes/improvements, make a pull request. 

## Dependencies

This script has no dependencies, meaning it can be drag-n-dropped.

## How to request data from the server to client?

Client:
```lua
-- Client side code:

local bank = exports['erp_remotecalls']:CallAsync('getBank' --[[ Event Name ]], {} --[[ Data being sent ]])
local vehicleInfo = exports['erp_remotecalls']:CallAsync('getVehicleInfo', { plate = 'ABC' })

print(bank, vehicleInfo)
```
Server:
```lua
-- Server side code:
AddEventHandler('getBank', function(source, data, cb) -- The name of the remote call.
	cb( 500 ) -- This is what we are returning.
end)

AddEventHandler('getVehicleInfo', function(source, data, cb) -- The name of the remote call.
	
	-- Here we will make use of promises when a callback type function is used like SQL.

	local plate = data.plate
	if not plate then cb(nil) return end; -- Returning nothing if no plate is sent, just as precaution.

	local p = promise.new() -- A promise.

	exports.oxmysql:execute('SELECT `owner` FROM `owned_vehicles` WHERE plate=:plate LIMIT 1', { plate = plate }, function(data) -- The query
		p:resolve(data) -- Resolving the data from the query
	end) 

	cb(Citizen.Await(p)) -- Sending back whatever was resolved.
	
end)
```

## How to request data from the client to server?

Client:
```lua
local stress = 50; -- Setting stress to 50.

AddEventHandler('getPlayerStress', function(data, cb) -- Name of remote call.
	cb( stress ) -- Returning the stress var which is a 50 int.
end)
```
Server:
```lua
-- Server side code:
local playerStress = exports['erp_remotecalls']:CallAsync(source --[[ Server ID of who to remote call ]], 'getPlayerStress' --[[ Name of remote call ]], {} --[[ Data sent to the client with the remote call ]])
```