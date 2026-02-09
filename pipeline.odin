package engine

import "core:container/priority_queue"
import "core:fmt"
import "vendor:wgpu"

code :: #load("wgsl/first.wgsl")

pipeline_data :: struct {
	
}

InitializePipeline :: proc(device: wgpu.Device, surface_format: wgpu.TextureFormat) -> wgpu.RenderPipeline {
	shader_mod_descriptor : wgpu.ShaderModuleDescriptor
	shader_mod_descriptor.label = "shader descriptor"
	
	shader_code_descriptor : wgpu.ShaderSourceWGSL
	shader_code_descriptor.chain.next = nil
	shader_code_descriptor.chain.sType = .ShaderSourceWGSL
	shader_code_descriptor.code = cast(string)code
	
	shader_mod_descriptor.nextInChain = &shader_code_descriptor.chain
	
	shader_module := wgpu.DeviceCreateShaderModule(device, &shader_mod_descriptor)
	
	pipeline_desc : wgpu.RenderPipelineDescriptor
	pipeline_desc.nextInChain = nil
	
	// [...] Describe vertex pipeline state
	pipeline_desc.vertex.bufferCount = 0
	pipeline_desc.vertex.buffers = nil
	
	pipeline_desc.vertex.module = shader_module
	pipeline_desc.vertex.entryPoint = "vs_main"
	pipeline_desc.vertex.constantCount = 0
	pipeline_desc.vertex.constants = nil
	
	// [...] Describe primitive pipeline state
	pipeline_desc.primitive.topology = .TriangleList
	pipeline_desc.primitive.stripIndexFormat = .Undefined
	pipeline_desc.primitive.frontFace = .CCW
	pipeline_desc.primitive.cullMode = .None
	
	// [...] Describe fragment pipeline state
	fragment_state : wgpu.FragmentState
	fragment_state.module = shader_module
	fragment_state.entryPoint = "fs_main"
	fragment_state.constantCount = 0
	fragment_state.constants = nil
	
	// [...] Describe stencil/depth pipeline state
	pipeline_desc.depthStencil = nil
	
	// [...] Describe blending state
	blend_state : wgpu.BlendState
	blend_state.color.srcFactor = .SrcAlpha
	blend_state.color.dstFactor = .OneMinusSrcAlpha
	blend_state.color.operation = .Add
	blend_state.alpha.srcFactor = .Zero
	blend_state.alpha.dstFactor = .One
	blend_state.alpha.operation = .Add
	
	color_target : wgpu.ColorTargetState
	color_target.format = surface_format
	color_target.blend = &blend_state
	color_target.writeMask = { .Red, .Blue, .Green, .Alpha }
	
	fragment_state.targetCount = 1
	fragment_state.targets = &color_target
	pipeline_desc.fragment = &fragment_state
	
	// [...] Describe multi-sampling state
	pipeline_desc.multisample.count = 1
	pipeline_desc.multisample.mask = 0xffffffff
	pipeline_desc.multisample.alphaToCoverageEnabled = false
	
	// [...] Describe pipeline layout
	pipeline_desc.layout = nil
	
	return wgpu.DeviceCreateRenderPipeline(device, &pipeline_desc)
}

