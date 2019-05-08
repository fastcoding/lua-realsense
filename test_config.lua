local ffi=require'ffi'
ffi.cdef[[
  int setenv(const char*name,const char* val,int ov);
]]

local pp=io.popen('cd ..;pwd')
local cwd=pp:read('*a')
cwd=cwd:gsub("[%s\r\n]*$",'')
pp:close()
local platformlibdir='./platform/'..ffi.os..'-'..ffi.arch --for platform so's
local extlibdir='./lib'  --for extra libs
package.path=cwd..'/?.lua;'..extlibdir..'/?.lua;'..cwd..'/share/lua/5.1/?.lua;'..cwd..'/ilock/?.lua;'..package.path
package.cpath=platformlibdir..'/?.so;'..package.cpath
ffi.C.setenv('LUA_PATH',package.path,1)
ffi.C.setenv('LUA_CPATH',package.cpath,1)

--require('remdebug.engine').start()
--require('mobdebug').start()
