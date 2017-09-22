
-- example script that demonstrates response handling and
-- retrieving an authentication token to set on all future
-- requests

user=math.random(99999999)
id=nil
login=nil
wrk.method = "POST"
wrk.body   = string.format('{"username": "%s","password": "%s", "email": "%s"}',user, user, user)
wrk.path = "/register"
wrk.headers["Content-Type"] = "application/json"


response = function(status, headers, body)
	if not id and status == 200 then
		id=(string.match(body,'"id":"(.*)"'))
		io.write("authentication done"
		wrk.method="GET"
	end

end