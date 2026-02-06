package engine

import "vendor:wgpu"
import "core:fmt"

request_device :: proc(adapter: wgpu.Adapter) -> wgpu.Device {
	descriptor : wgpu.DeviceDescriptor
	descriptor.nextInChain = nil
	descriptor.label = "cock engine"
	descriptor.requiredLimits = nil
	descriptor.defaultQueue.nextInChain = nil
	descriptor.defaultQueue.label = "default queue"
	
	descriptor.deviceLostCallbackInfo.mode = .WaitAnyOnly
	descriptor.deviceLostCallbackInfo.nextInChain = nil
	descriptor.deviceLostCallbackInfo.userdata1 = nil
	descriptor.deviceLostCallbackInfo.callback = proc "c" (device: ^wgpu.Device, reason: wgpu.DeviceLostReason, message: wgpu.StringView, userdata1: rawptr, userdata2: rawptr) {
		context = state.ctx
		fmt.print("Devise lost: reason", message)
	}
	
	descriptor.uncapturedErrorCallbackInfo.nextInChain = nil
	descriptor.uncapturedErrorCallbackInfo.userdata1 = nil
	descriptor.uncapturedErrorCallbackInfo.callback = proc "c" (device: ^wgpu.Device, type: wgpu.ErrorType, message: wgpu.StringView, userdata1: rawptr, userdata2: rawptr) {
		context = state.ctx
		fmt.print("Uncapture devise error: type", type)
	}
	
	UserData :: struct {
		devise: wgpu.Device,
		requestEnded: bool,
	}
	
	data : UserData
	
	onrequestend :: proc "c" (status: wgpu.RequestDeviceStatus, adapter: wgpu.Device, message: wgpu.StringView, userdata1: rawptr, userdata2: rawptr) {
		data := cast(^UserData)userdata1
		
		if status == .Success {
			data.devise = adapter
		} else {
			data.devise = nil
		}
		
		data.requestEnded = true
	}
	
	info : wgpu.RequestDeviceCallbackInfo
	
	info.callback = onrequestend
	info.mode = .WaitAnyOnly
	info.userdata1 = &data
	info.userdata2 = nil
	
	wgpu.AdapterRequestDevice(adapter, &descriptor, info)

	return data.devise
}

print_device_info :: proc(device: wgpu.Device) {
	features := wgpu.DeviceGetFeatures(device)
	fmt.println("Devise features: ", features.featureCount)
	for i : uint = 0; i < features.featureCount; i += 1 {
		fmt.println("  feature ", i, ": ", features.features[i])
	}
	
	limits, status := wgpu.DeviceGetLimits(device)
	
	if status == .Success {
		fmt.println("Device limits")
		fmt.println("  maxTextureDimension1D: ", limits.maxTextureDimension1D)
		fmt.println("  maxTextureDimension2D: ", limits.maxTextureDimension2D)
		fmt.println("  maxTextureDimension3D: ", limits.maxTextureDimension3D)
		fmt.println("  maxTextureArrayLayers: ", limits.maxTextureArrayLayers)
	}
}