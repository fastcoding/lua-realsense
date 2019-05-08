require('test_config')
--require('mobdebug').start()
local ffi=require'ffi'
local time=require'time'
local rs2=require'realsense.core'
local ctx=rs2.context()
local lst=ctx:query_devices()
local cnt=lst:count()
print('has '..cnt..' devices')
local HEIGHT_RATIO=20
local WIDTH_RATIO=10
local pixels = ffi.new('char[9]'," .:nhBXWW")
local int_arr=ffi.typeof('int[?]')

function test()
	local dev=lst:create_device(0)
	dev:print()
	local ok,unit=dev:get_depth_unit_value()
	local one_meter=1.0/unit	
	local cfg=rs2.create_config()
	cfg:enable_stream(rs2.lib.RS2_STREAM_DEPTH, 0, 640, 0, rs2.lib.RS2_FORMAT_Z16, 30)
	local pipeline = ctx:create_pipeline()
	print('create pipeline')
	local pipeline_profile=assert(pipeline:start_with_config(cfg))
	local stream_profile_list=pipeline_profile:profile_get_streams()
	local stream_profile=stream_profile_list:get_stream_profile(0)
	local streaminfo=stream_profile:get_stream_profile_data()
	local resolution=stream_profile:get_video_stream_resolution()
	
	local rows = resolution.height / HEIGHT_RATIO;
    local row_length = resolution.width / WIDTH_RATIO;
    local display_size = (rows + 1) * (row_length + 1);
    local buffer_size = display_size * ffi.sizeof('char');
	local buffer =assert(ffi.new('char[?]',buffer_size))
	print('buffer size=',buffer_size)
	local st_time=time.clock()
	local fps=0
	while true do
		local t=time.clock()		
		local frames=pipeline:wait_for_frames(rs2.RS2_DEFAULT_TIMEOUT)
		local cnt=frames:embedded_frames_count()
		local t0=time.clock()		
		--print('took ',(t0-t),' secs in getting frame')
		for i=1,cnt do
			local frame=frames:extract_frame(i-1)
			if frame:is_frame_extendable_to(rs2.lib.RS2_EXTENSION_DEPTH_FRAME)~=0 then 				
				local depth_frame_data=assert(ffi.cast('uint16_t*',frame:get_frame_data()))
				local o=0
				local coverage=assert(int_arr(display_size))
				local out=buffer
				local p=depth_frame_data
				local n=0
				for y=1,resolution.height do
					for x=1,resolution.width do
						local coverage_index = x / WIDTH_RATIO
						local depth = p[0]
						p=p+1
						if depth > 0 and depth < one_meter then 
							local d=coverage[coverage_index]
							coverage[coverage_index]=d+1
						end
					end
					if (y%HEIGHT_RATIO)==HEIGHT_RATIO-1 then 
						for k=1,row_length do
							local pixel_index = math.floor(coverage[k-1] / (HEIGHT_RATIO * WIDTH_RATIO / ffi.sizeof(pixels)))
							local px=pixels[pixel_index]						
							if n>buffer_size then 
								print('wrong !!!n=',n,' >',buffer_size)
							end
							out[0]=px
							out=out+1
							n=n+1							
							coverage[k-1]=0
						end
						out[0]=13
						out=out+1
					end
				end
				out[0]=0
				out=out+1
				if DEBUG then 
					ffi.C.printf("size=%d: %s\n",ffi.new('int',n),buffer)
				else 
					ffi.C.printf("%s\n",buffer)
				end
				fps=fps+1
			end	--endif
			frame:release();
		end --end of for frames
		local t1=time.clock()
		if t1-st_time>5 then 
			print('FPS=',fps/5)
			fps=0
			st_time=t1
		end
		--print('took ',(time.clock()-t0),' secs in loop')
		frames:release()
	end  --end of for true
	pipeline:pipeline_stop()
end

if cnt>0 then 
	local ok,msg=pcall(test)
	if not ok then 
		print(msg)
	end
end
lst:delete()
print('done')
os.exit(0)
