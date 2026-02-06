package engine

import "vendor:wgpu"
import "core:fmt"

main :: proc() {
	// ========= create instance =========
	desc : wgpu.InstanceDescriptor
	desc.nextInChain = nil
	instance : wgpu.Instance = wgpu.CreateInstance(&desc)
	if instance == nil {
		panic("WebGPU is not supported")
	}
	defer wgpu.InstanceRelease(instance)
	fmt.println("WebGPU is supported")
	
	// ========= request adapter =========
	adapter_options : wgpu.RequestAdapterOptions
	adapter_options.nextInChain = nil
	adapter := request_adapter(instance, nil)
	if adapter == nil {
		panic("request adapter failure")
	}
	defer wgpu.AdapterRelease(adapter)
	fmt.println("Got the adapter")
	
	//print_adapter_info(adapter)
	
	// ========= request device =========
	device := request_device(adapter)
	if device == nil {
		panic("request device failure")
	}
	defer wgpu.DeviceRelease(device)
	fmt.println("Got the device")
	
	print_device_info(device)
}