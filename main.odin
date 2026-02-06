package engine

import "vendor:wgpu"
import "vendor:wgpu/glfwglue"
import "vendor:glfw"
import "core:fmt"
import "base:runtime"

state : struct {
	ctx: runtime.Context
}

main :: proc() {
	state.ctx = context

	// ========= glfw =========
	if !glfw.Init() {
		panic("[glfw] init failure")
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	window := glfw.CreateWindow(960, 540, "WGPU Native Triangle", nil, nil)
	if window == nil {
		panic("Could not open window!")
	}
	defer glfw.DestroyWindow(window)

	// ========= create instance =========
	desc : wgpu.InstanceDescriptor
	desc.nextInChain = nil
	instance : wgpu.Instance = wgpu.CreateInstance(&desc)
	if instance == nil {
		panic("WebGPU is not supported")
	}
	defer wgpu.InstanceRelease(instance)
	fmt.println("WebGPU is supported")

	// ========= surface =========
	surface := glfwglue.GetSurface(instance, window)
	defer wgpu.SurfaceRelease(surface)
	
	// ========= request adapter =========
	adapter_options : wgpu.RequestAdapterOptions
	adapter_options.nextInChain = nil
	adapter_options.compatibleSurface = surface
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
	
	// ========= queue =========
	queue := wgpu.DeviceGetQueue(device)
	defer wgpu.QueueRelease(queue)
	queue_info(queue)
	command_encoder(device, queue)
	wgpu.DevicePoll(device, false)
	
	// ========= infitine loop =========
	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()
	}
}