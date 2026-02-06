package engine

import "base:runtime"
import "core:fmt"
import "vendor:glfw"
import "vendor:wgpu"
import "vendor:wgpu/glfwglue"

state: struct {
	ctx: runtime.Context,
}

main :: proc() {
	state.ctx = context

	// ========= glfw =========
	if !glfw.Init() {
		panic("[glfw] init failure")
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	glfw.WindowHint(glfw.RESIZABLE, glfw.FALSE)
	window := glfw.CreateWindow(960, 540, "WGPU Native Triangle", nil, nil)
	if window == nil {
		panic("Could not open window!")
	}
	defer glfw.DestroyWindow(window)

	// ========= create instance =========
	desc: wgpu.InstanceDescriptor
	desc.nextInChain = nil
	instance: wgpu.Instance = wgpu.CreateInstance(&desc)
	if instance == nil {
		panic("WebGPU is not supported")
	}
	fmt.println("WebGPU is supported")

	// ========= surface =========
	surface := glfwglue.GetSurface(instance, window)
	defer wgpu.SurfaceRelease(surface)

	// ========= request adapter =========
	adapter_options: wgpu.RequestAdapterOptions
	adapter_options.nextInChain = nil
	adapter_options.compatibleSurface = surface
	adapter := request_adapter(instance, &adapter_options)
	if adapter == nil {
		panic("request adapter failure")
	}
	defer wgpu.AdapterRelease(adapter)
	wgpu.InstanceRelease(instance)
	fmt.println("Got the adapter")

	//print_adapter_info(adapter)

	// ========= surface capabilities =========
	surface_capabilities, status := wgpu.SurfaceGetCapabilities(surface, adapter)
	if status != .Success {
		panic("could not get surface capabilities")
	}

	// ========= request device =========
	device := request_device(adapter)
	if device == nil {
		panic("request device failure")
	}
	defer wgpu.DeviceRelease(device)
	fmt.println("Got the device")
	//print_device_info(device)

	// ========= queue =========
	queue := wgpu.DeviceGetQueue(device)
	defer wgpu.QueueRelease(queue)
	queue_info(queue)
	//command_encoder(device, queue)

	fmt.println("queue made")

	// ========= surface configuration =========
	surface_config: wgpu.SurfaceConfiguration
	surface_config.nextInChain = nil
	surface_config.width = 960
	surface_config.height = 540
	surface_config.usage = {.RenderAttachment}
	surface_config.format = surface_capabilities.formats[0]
	surface_config.viewFormatCount = 0
	surface_config.viewFormats = nil
	surface_config.device = device
	surface_config.presentMode = .Fifo
	surface_config.alphaMode = .Auto

	wgpu.SurfaceConfigure(surface, &surface_config)

	fmt.println("surface configured")


	// ========= infitine loop =========
	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		// ========= surface texture =========
		surface_texture, target_view := get_next_surface_data(surface)
		if target_view == nil {
			break
		}
		defer wgpu.TextureRelease(surface_texture.texture)

		// ========= commands =========
		commands: [dynamic]wgpu.CommandBuffer
		// ========= commands encoder =========
		encoder_desc: wgpu.CommandEncoderDescriptor
		encoder_desc.nextInChain = nil
		encoder_desc.label = "my command encoder"

		encoder := wgpu.DeviceCreateCommandEncoder(device, &encoder_desc)
		wgpu.CommandEncoderInsertDebugMarker(encoder, "do one thing")
		wgpu.CommandEncoderInsertDebugMarker(encoder, "do another thing")

		//fmt.println("command encoder configured")

		// ========= render pass color attachment =========
		render_pass_color_attachment: [1]wgpu.RenderPassColorAttachment
		render_pass_color_attachment[0].view = target_view
		render_pass_color_attachment[0].resolveTarget = nil
		render_pass_color_attachment[0].loadOp = .Clear
		render_pass_color_attachment[0].storeOp = .Store
		render_pass_color_attachment[0].clearValue = {0.9, 0.1, 0.2, 1}
		render_pass_color_attachment[0].depthSlice = wgpu.DEPTH_SLICE_UNDEFINED

		rend_pass_col_attc_list: [^]wgpu.RenderPassColorAttachment = raw_data(
			render_pass_color_attachment[:],
		)

		// ========= render pass descriptor =========
		render_pass_desc: wgpu.RenderPassDescriptor
		render_pass_desc.nextInChain = nil
		render_pass_desc.colorAttachmentCount = 1
		render_pass_desc.colorAttachments = rend_pass_col_attc_list
		render_pass_desc.depthStencilAttachment = nil
		render_pass_desc.timestampWrites = nil

		// ========= render pass encoder =========
		render_pass := wgpu.CommandEncoderBeginRenderPass(encoder, &render_pass_desc)
		wgpu.RenderPassEncoderEnd(render_pass)
		wgpu.RenderPassEncoderRelease(render_pass)

		//fmt.println("render pass encoder configured")

		buffer_desc: wgpu.CommandBufferDescriptor
		buffer_desc.nextInChain = nil
		buffer_desc.label = "my command encoder"
		command := wgpu.CommandEncoderFinish(encoder, &buffer_desc)
		append(&commands, command)
		//defer pop(&commands)
		wgpu.CommandEncoderRelease(encoder)

		//fmt.println("submitting commands...")
		wgpu.QueueSubmit(queue, commands[:])
		for command in commands {
			wgpu.CommandBufferRelease(command)
		}
		//fmt.println("commands submitted.")

		wgpu.TextureViewRelease(target_view)
		wgpu.SurfacePresent(surface)
		wgpu.DevicePoll(device, false)
	}
}
