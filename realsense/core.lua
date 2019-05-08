local ffi=require'ffi'
local librs2=require'realsense.lib'

local _M={
	RS2_API_MAJOR_VERSION=2,
	RS2_API_MINOR_VERSION=21,
	RS2_API_PATCH_VERSION=0,
	RS2_API_BUILD_VERSION=0,
	RS2_DEFAULT_TIMEOUT=15000
}

_M.RS2_API_VERSION = (((_M.RS2_API_MAJOR_VERSION) * 10000) + ((_M.RS2_API_MINOR_VERSION) * 100) + (_M.RS2_API_PATCH_VERSION))

--param:rs2_error* 
function check_error(es,r) 
	local e=es[0]
    if e~=nil then     
        ffi.C.printf("rs_error was raised when calling %s(%s):\n", librs2.rs2_get_failed_function(e),librs2.rs2_get_failed_args(e))
        ffi.C.printf("    %s\n", librs2.rs2_get_error_message(e))
		return nil,e
    end
	return r
end


function _M.context()
	local ctx=librs2.rs2_create_context(_M.RS2_API_VERSION, e)
	ffi.gc(ctx,function(self)
			self:delete()
		end)
	return ctx
end

function _M.create_config()
	local e =ffi.new('rs2_error*[1]')
	local config = librs2.rs2_create_config(e)
	if config then 
		ffi.gc(config,function(d) d:delete() end)
	end
	return check_error(e,config)
end

_M.lib=librs2

return _M



