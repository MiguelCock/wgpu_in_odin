package engine

import "vendor:wgpu"
import "core:fmt"

request_adapter :: proc(instance: wgpu.Instance, options: ^wgpu.RequestAdapterOptions) -> wgpu.Adapter {
	UserData :: struct {
		adapter: wgpu.Adapter,
		requestEnded: bool,
	}
	
	data : UserData
	
	onrequestend :: proc "c" (status: wgpu.RequestAdapterStatus, adapter: wgpu.Adapter, message: string, userdata1: rawptr, userdata2: rawptr) {
		data := cast(^UserData)userdata1
		if status == .Success && adapter != nil {
			data.adapter = adapter
		} else {
			data.adapter = nil
		}
		
		data.requestEnded = true
	}
	
	info := wgpu.RequestAdapterCallbackInfo{
		nextInChain = nil,
		mode = wgpu.CallbackMode.WaitAnyOnly,
		callback = onrequestend,
		userdata1 = &data,
	}
	
	wgpu.InstanceRequestAdapter(instance, options, info)
	
	return data.adapter
}

print_adapter_info :: proc(adapter: wgpu.Adapter) {
	// ========= adapter limits =========
	limits, succes := wgpu.AdapterGetLimits(adapter)
	if succes != .Success {
		panic("get adapter limits failure")
	}
	fmt.println("adapter limits:")
	fmt.println("  maxBindingsPerBindGroup: ", limits.maxBindingsPerBindGroup)
	fmt.println("  maxDynamicUniformBuffersPerPipelineLayout: ", limits.maxDynamicUniformBuffersPerPipelineLayout)
	fmt.println("  maxDynamicStorageBuffersPerPipelineLayout: ", limits.maxDynamicStorageBuffersPerPipelineLayout)
	fmt.println("  maxSampledTexturesPerShaderStage: ", limits.maxSampledTexturesPerShaderStage)
	fmt.println("  maxSamplersPerShaderStage: ", limits.maxSamplersPerShaderStage)
	fmt.println("  maxStorageBuffersPerShaderStage: ", limits.maxStorageBuffersPerShaderStage)
	fmt.println("  maxStorageTexturesPerShaderStage: ", limits.maxStorageTexturesPerShaderStage)
	fmt.println("  maxUniformBuffersPerShaderStage: ", limits.maxUniformBuffersPerShaderStage)
	fmt.println("  maxUniformBufferBindingSize: ", limits.maxUniformBufferBindingSize)
	fmt.println("  maxStorageBufferBindingSize: ", limits.maxStorageBufferBindingSize)
	fmt.println("  minUniformBufferOffsetAlignment: ", limits.minUniformBufferOffsetAlignment)
	
	// ========= adapter features =========
	features := wgpu.AdapterGetFeatures(adapter)
	fmt.println("adapter features:")
	for i : uint = 0; i < features.featureCount; i += 1 {
		fmt.println("  feature ", i, ": ", features.features[i])
	}
	/*
		feature  0 :  DepthClipControl
		feature  1 :  Depth32FloatStencil8
		feature  2 :  TextureCompressionBC
		feature  3 :  TimestampQuery
		feature  4 :  IndirectFirstInstance
		feature  5 :  ShaderF16
		feature  6 :  RG11B10UfloatRenderable
		feature  7 :  BGRA8UnormStorage
		feature  8 :  Float32Filterable
		feature  9 :  DualSourceBlending
		feature  10 :  PushConstants
		feature  11 :  TextureAdapterSpecificFormatFeatures
		feature  12 :  MultiDrawIndirectCount
		feature  13 :  VertexWritableStorage
		feature  14 :  TextureBindingArray
		feature  15 :  SampledTextureAndStorageBufferArrayNonUniformIndexing
		feature  16 :  PipelineStatisticsQuery
		feature  17 :  StorageResourceBindingArray
		feature  18 :  PartiallyBoundBindingArray
		feature  19 :  TextureFormat16bitNorm
		feature  20 :  TimestampQueryInsidePasses
		feature  21 :  TimestampQueryInsideEncoders
		feature  22 :  MappablePrimaryBuffers
		feature  23 :  BufferBindingArray
		feature  24 :  PolygonModeLine
		feature  25 :  PolygonModePoint
		feature  26 :  ConservativeRasterization
		feature  27 :  TextureFormatNv12
		feature  28 :  ShaderF64
		feature  29 :  ShaderInt64
		feature  30 :  ShaderI16
		feature  31 :  ShaderPrimitiveIndex
		feature  32 :  ShaderEarlyDepthTest
		feature  33 :  Subgroup
		feature  34 :  SubgroupVertex
		feature  35 :  SubgroupBarrier
		feature  36 :  %!(BAD ENUM VALUE=7012452)
	*/
	
	// ========= adapter properties =========
	info, status := wgpu.AdapterGetInfo(adapter)
	fmt.println("adapter properties")
	fmt.println("  vendor name: ", info.vendor)
	fmt.println("  device name: ", info.device)
	fmt.println("  architecture name: ", info.architecture)
	fmt.println("  description: ", info.description)
	fmt.println("  backend type: ", info.backendType)
	fmt.println("  adapter type: ", info.adapterType)
	fmt.printfln("  device id: ", info.deviceID)
	fmt.println("  vendor id: ", info.vendorID)
}