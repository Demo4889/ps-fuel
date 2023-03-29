function versionCheck(repository)
	local resource = GetInvokingResource() or GetCurrentResourceName()

	local currentVersion = GetResourceMetadata(resource, 'version', 0)

	if currentVersion then
		currentVersion = currentVersion:match('%d+%.%d+%.%d+')
	end

	if not currentVersion then return print(("^1Unable to determine current resource version for '%s' ^0"):format(resource)) end

	SetTimeout(1000, function()
		PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repository), function(status, response)
			if status ~= 200 then return end

			response = json.decode(response)

			if response.prerelease then return end

			local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')
			if not latestVersion or latestVersion == currentVersion then return end

            local cv = { string.strsplit('.', currentVersion) }
            local lv = { string.strsplit('.', latestVersion) }

            for i = 1, #cv do
                local current, minimum = tonumber(cv[i]), tonumber(lv[i])
                if current ~= minimum then
                    if current < minimum then

                        print("^0.-----------------------------------------------.")
                        print("^0|                 Project Sloth                 |")
                        print("^0'-----------------------------------------------'")
                        print(('^6Your %s is outdated (your version: %s)\r\nMake sure to update: %s^0'):format(resource, currentVersion, response.html_url))
                        print('^2'..response.body:gsub("\r\n\r\n\r", "^0"))

                       
                else break end
                end
            end
		end, 'GET')
	end)
end

versionCheck('Project-Sloth/ps-fuel')
