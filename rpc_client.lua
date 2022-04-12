local RPC = {

	-- CLIENT -> SERVER

	CallAsync = function(self, eventName, data)

		local p = promise.new()	
		local callId = #self.ActiveCalls + 1
		self.ActiveCalls[callId] = p
		
		TriggerServerEvent('erp_remotecalls:sendCall', callId, eventName, data)

		return Citizen.Await(p)

	end,

	GetData = function(self, callId, ...)

		local p = self.ActiveCalls[callId]
		p:resolve(...)

		self.ActiveCalls[callId] = false

	end,

	-- SERVER -> CLIENT

	ActiveCalls = {},

	SendCall = function(self, eventName, data)

        local p = promise.new()

        TriggerEvent(eventName, data, function(returnVal)
            p:resolve(returnVal)
        end)

        return Citizen.Await(p)

    end,

}

-- CLIENT -> SERVER

RegisterNetEvent('erp_remotecalls:getData', function(callId, ...)
	RPC:GetData(callId, ...)
end)

exports('CallAsync', function(event, data)
	return RPC:CallAsync(event, data)
end)

-- exports['erp_remotecalls']:CallAsync()

-- SERVER -> CLIENT

RegisterNetEvent('erp_remotecalls:sendCall', function(callId, eventName, data)
    TriggerServerEvent('erp_remotecalls:getData', callId, RPC:SendCall(eventName, data))
end)