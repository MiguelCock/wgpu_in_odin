package engine

import "vendor:wgpu"
import "core:fmt"

queue_info :: proc (queue: wgpu.Queue) {
    info : wgpu.QueueWorkDoneCallbackInfo
	info.mode = .AllowProcessEvents
	info.nextInChain = nil
	info.userdata1 = nil
	info.callback = proc "c" (status: wgpu.QueueWorkDoneStatus, userdata1: rawptr, userdata2: rawptr) {
		context = state.ctx

		fmt.println("Queued work finished with status: ", status)
	}
	wgpu.QueueOnSubmittedWorkDone(queue, info)
}

command_encoder :: proc(device: wgpu.Device, queue: wgpu.Queue) {
    commands : [dynamic]wgpu.CommandBuffer
	defer {
		for command in commands {
			wgpu.CommandBufferRelease(command)
		}
	}

    encoder_desc : wgpu.CommandEncoderDescriptor
    encoder_desc.nextInChain = nil
    encoder_desc.label = "my command encoder"

    encoder := wgpu.DeviceCreateCommandEncoder(device, &encoder_desc)
    wgpu.CommandEncoderInsertDebugMarker(encoder, "do one thing")
    wgpu.CommandEncoderInsertDebugMarker(encoder, "do another thing")
    
    buffer_desc : wgpu.CommandBufferDescriptor
    buffer_desc.nextInChain = nil
    buffer_desc.label = "my command encoder"
    append(&commands, wgpu.CommandEncoderFinish(encoder, &buffer_desc))

    fmt.println("submitting commands...")
    wgpu.QueueSubmit(queue, commands[:])
    fmt.println("commands submitted.")
}