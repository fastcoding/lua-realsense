require('test_config')
require('mobdebug').start()
local rs2=require'realsense.core'
local ctx=rs2.context()
local lst=ctx:query_devices()
local cnt=lst:count()
print('has '..cnt..' devices')

function test()	
	local dev=lst:create_device(0)
	dev:print()
	local pipeline = ctx:create_pipeline()
	local cfg=rs2.create_config()
	cfg:enable_stream(rs2.lib.RS2_STREAM_COLOR, 0, 640, 480, rs2.lib.RS2_FORMAT_RGB8, 30)
	local pipeline_profile=assert(pipeline:start_with_config(cfg))
	while true do
		local frames=pipeline:wait_for_frames(rs2.RS2_DEFAULT_TIMEOUT)
		local cnt=frames:embedded_frames_count()
		for i=1,cnt do
			local frame=frames:extract_frame(i-1)
			local rgb_frame_data=frame:get_frame_data()
			local frame_num=frame:get_frame_number()
			local frame_timestamp=frame:get_frame_timestamp()
			local frame_timestamp_domain=frame:get_frame_timestamp_domain()
			local frame_metadata_time_of_arrival=frame:get_frame_metadata(rs2.lib.RS2_FRAME_METADATA_TIME_OF_ARRIVAL)
			print("RGB frame arrived")
			print("First 10 bytes: ")
			for i=1,10 do
				io.stderr:write(string.format("%02x ", rgb_frame_data[i]))
			end
			print("Frame No:", frame_num)
			print("Timestamp:", frame_timestamp);
			print("Timestamp domain: ", frame_timestamp_domain);
			print("Time of arrival:", frame_metadata_time_of_arrival);
			frame:release();
		end
		frames:release()
	end
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
