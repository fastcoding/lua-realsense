local ffi=require'realsense.h'
local lib=ffi.load('librealsense2')
local e =ffi.new('rs2_error*[1]')
local function chkerr(es,r)
	local err=es[0]
	if err~=nil then
		ffi.C.printf("rs_error was raised when calling %s(%s):\n", lib.rs2_get_failed_function(err), lib.rs2_get_failed_args(err))
        ffi.C.printf("    %s\n", lib.rs2_get_error_message(err))
		return nil,err
	end
	return r
end
	
ffi.metatype('rs2_context',{
	__index={
		query_devices=function(self)
			return lib.rs2_query_devices(self, e), e[0]			
		end,
		delete=function(self)
			lib.rs2_delete_context(self)
		end,
		create_pipeline=function(ctx)			
			local pipeline =  lib.rs2_create_pipeline(ctx, e)
			if pipeline then 
				ffi.gc(pipeline,function(d) d:delete() end)
			end
			return chkerr(e,pipeline)
		end,
		create_config=function(ctx)			
			local config =  lib.rs2_create_config(ctx, e)
			return chkerr(e,config)
		end
	}
})

ffi.metatype('rs2_config',{__index={
		enable_stream=function (self,strm,idx,width,height,fmt,fps)
			return chkerr(e,lib.rs2_config_enable_stream(self,strm,idx,width,height,fmt,fps,e))
		end,
		delete=function(self)
			lib.rs2_delete_config(self)
		end
}})

ffi.metatype('rs2_pipeline_profile',{__index={
			delete=function(prof)
				lib.rs2_delete_pipeline_profile(prof)
			end	,
			--return rs2_stream_profile_list
			profile_get_streams=function(self)
				return chkerr(e,lib.rs2_pipeline_profile_get_streams(self,e))
			end
			
		}
	}
)

ffi.metatype('rs2_pipeline',{__index={
			delete=function(d)
				lib.rs2_delete_pipeline(d)				
			end,
			start_with_config=function (self,config)				
				local profile=lib.rs2_pipeline_start_with_config(self,config,e)				
				if profile then 
					ffi.gc(profile,function(prof)
						prof:delete()
					end)
				end
				return chkerr(e,profile)
			end,
			wait_for_frames=function(self,timeout)
				local frames=lib.rs2_pipeline_wait_for_frames(self,timeout, e)			
				return chkerr(e,frames)
			end,
			pipeline_stop=function(self)
				return chkerr(e,lib.rs2_pipeline_stop(self,e))
			end
}})

ffi.metatype('rs2_device',{__index={		
	print=function(dev)
		print("\nUsing device 0, an ", dev:get_device_info(lib.RS2_CAMERA_INFO_NAME))
 		print("    Serial number: ", dev:get_device_info(lib.RS2_CAMERA_INFO_SERIAL_NUMBER))
		print("    Firmware version: ", dev:get_device_info(lib.RS2_CAMERA_INFO_FIRMWARE_VERSION)		)
	end,
	delete=function(self)
		lib.rs2_delete_device(self)
	end,
	get_device_info=function(self,info)
		return chkerr(e,ffi.string(lib.rs2_get_device_info(self, info,e)))
	end,
	query_sensors=function(self)
		local lst=lib.rs2_query_sensors(self, e)
		if chkerr(e,lst) then 
			ffi.gc(lst,function(l) l:delete() end)
			return lst
		end
		return nil,e[0]
	end,
	get_depth_unit_value=function(self)
		local sensor_list = self:query_sensors(e)
		local num_of_sensors=sensor_list:get_sensors_count()		
		for i=1,num_of_sensors do
			local sensor=sensor_list:create_sensor(i-1)
			if sensor:is_depth_sensor_found() then 
				local depth_scale=sensor:depth_scale()
				--sensor:delete()
				return true,depth_scale
			end
			sensor:delete()
		end	
		return false
	end
	}
})

ffi.metatype('rs2_sensor',{__index={
			delete=function(self)
				return lib.rs2_delete_sensor(self)
			end,
			is_depth_sensor_found=function(self)
				return chkerr(e,lib.rs2_is_sensor_extendable_to(self,lib.RS2_EXTENSION_DEPTH_SENSOR,e))
			end,
			depth_scale=function(self)
				return chkerr(e,lib.rs2_get_option(ffi.cast('const rs2_options_list*',self),lib.RS2_OPTION_DEPTH_UNITS,e))
			end
		}
	}
)


ffi.metatype('rs2_sensor_list',{__index={
			get_sensors_count=function(self)
				return chkerr(e,lib.rs2_get_sensors_count(self,e))
			end,
			create_sensor=function(self,idx)
				local sensor=lib.rs2_create_sensor(self,idx,e)
				if chkerr(e,sensor) then 
				   ffi.gc(sensor,function(s) s:delete() end)
					return sensor   
				end
				return nil,e[0]
			end,
			delete=function(self)
				return lib.rs2_delete_sensor_list(self)
			end
		}
	}
)

ffi.metatype('rs2_stream_profile',{__index={
			delete=function(self)
				return lib.rs2_delete_stream_profile(self)
			end,
			get_stream_profile_data=function(self)
				local pstream=ffi.new('rs2_stream[1]')
				local pfmt=ffi.new('rs2_format[1]')
				local pindex=ffi.new('int[1]')
				local punique_id=ffi.new('int[1]')
				local pframerate=ffi.new('int[1]')
				local r,err=chkerr(e,lib.rs2_get_stream_profile_data(self,
						pstream,
						pfmt,
						pindex,
						punique_id,
						pframerate,
						e))
				if err then 
				   return nil,err
				end
				return {
						stream=pstream[0],
						format=pfmt[0],
						index=pindex[0],
						unique_id=punique_id[0],
						framerate=pframerate[0]
					}
			end,
			get_video_stream_resolution=function(self)
				local pwidth=ffi.new('int[1]')
				local pheight=ffi.new('int[1]')
				lib.rs2_get_video_stream_resolution(self,pwidth,pheight,e)
				if chkerr(e,true) then 
					return {width=pwidth[0],height=pheight[0]}
				end
				return nil,e[0]
			end
		}
	}
)

ffi.metatype('rs2_stream_profile_list',{__index={
			delete=function(self)
				return lib.rs2_delete_stream_profiles_list(self)
			end,
			get_stream_profile=function(self,idx)
				return chkerr(e,lib.rs2_get_stream_profile(self,idx,e))
			end
		}
	}
)


ffi.metatype('rs2_device_list',{
	__index={
		count=function(self) 			
			return lib.rs2_get_device_count(self, e), e[0]			
		end	,
		delete=function(self)
			lib.rs2_delete_device_list(self)
		end,
		create_device=function(self,x)
			if not x then x=0 end			
			local dev = lib.rs2_create_device(self, x, e)
			ffi.gc(dev,function(d) dev:delete() end)
			return chkerr(e,dev)
		end
	}
})

ffi.metatype('rs2_frame',{
		__index={
				embedded_frames_count=function(self)					
					return chkerr(e,lib.rs2_embedded_frames_count(self,e))
				end,
				release=function(self)
					lib.rs2_release_frame(self)
				end,
				is_frame_extendable_to=function(self,c)
					return chkerr(e,lib.rs2_is_frame_extendable_to(self,c,e)) --lib.RS2_EXTENSION_DEPTH_FRAME
				end,
				extract_frame=function(self,idx)
					return chkerr(e,lib.rs2_extract_frame(self,idx,e))
				end,
				get_frame_data=function(self)
					return chkerr(e,lib.rs2_get_frame_data(self,e))
				end,
				get_frame_number=function(self)
					return chkerr(e,lib.rs2_get_frame_number(self,e))
				end,
				get_frame_timestamp=function(self)					
					return chkerr(e,lib.rs2_get_frame_timestamp(self,e))
				end,
				get_frame_timestamp_domain=function(self)
					local domain=lib.rs2_get_frame_timestamp_domain(self,e)
					if domain then 
						return ffi.string(lib.rs2_timestamp_domain_to_string(domain))
					end
					return e[0]
				end,
				get_frame_height=function(self)
					return chkerr(e,lib.rs2_get_frame_height(self,e))
				end,
				get_frame_width=function(self)
					return chkerr(e,lib.rs2_get_frame_width(self,e))
				end,
				get_frame_stride_in_bytes=function(self)
					return chkerr(e,lib.rs2_get_frame_stride_in_bytes(self,e))
				end,
				get_frame_metadata=function(self,metadatavalue)					
					return chkerr(e,lib.rs2_get_frame_metadata(self,metadatavalue,e))
				end
		}
	}
)

return lib

