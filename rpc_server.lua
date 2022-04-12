local RPC = {

    -- SERVER -> CLIENT

    SendCall = function(self, source, eventName, data)

        local p = promise.new()

        TriggerEvent(eventName, source, data, function(returnVal)
            p:resolve(returnVal)
        end)

        return Citizen.Await(p)

    end,

    -- CLIENT -> SERVER

    ActiveCalls = {},

    CallAsync = function(self, source, eventName, data)
        
		local p = promise.new()	
		local callId = #self.ActiveCalls + 1
		self.ActiveCalls[callId] = p
		
		TriggerClientEvent('erp_remotecalls:sendCall', source, callId, eventName, data)

		return Citizen.Await(p)

	end,

	GetData = function(self, callId, ...)

		local p = self.ActiveCalls[callId]
		p:resolve(...)

		self.ActiveCalls[callId] = false

	end,

}

RegisterNetEvent('erp_remotecalls:sendCall', function(callId, eventName, data)
    local source = source;
    TriggerClientEvent('erp_remotecalls:getData', source, callId, RPC:SendCall(source, eventName, data))
end)

exports('CallAsync', function(source, event, data)
	return RPC:CallAsync(source, event, data)
end)

-- exports['erp_remotecalls']:CallAsync()

RegisterNetEvent('erp_remotecalls:getData', function(callId, ...)
	RPC:GetData(callId, ...)
end)