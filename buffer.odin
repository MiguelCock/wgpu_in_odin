package engine

import "core:fmt"
import "vendor:wgpu"

create_buffer :: proc(device: wgpu.Device, queue: wgpu.Queue) {
	buffer_desc: wgpu.BufferDescriptor
	buffer_desc.nextInChain = nil
	buffer_desc.label = "some data buffer"
	buffer_desc.usage = {.CopyDst, .CopySrc}
	buffer_desc.size = 16
	buffer_desc.mappedAtCreation = false

	buffer_1 := wgpu.DeviceCreateBuffer(device, &buffer_desc)
	defer wgpu.BufferRelease(buffer_1)

	buffer_desc.label = "Output buffer"
	buffer_desc.usage = {.CopyDst, .MapRead}
	buffer_2 := wgpu.DeviceCreateBuffer(device, &buffer_desc)
	defer wgpu.BufferRelease(buffer_2)

	data: [16]byte
	for i: byte = 0; i < 16; i += 1 do data[i] = i
	wgpu.QueueWriteBuffer(queue, buffer_1, 0, &data, 16)

	encoder := wgpu.DeviceCreateCommandEncoder(device)

	wgpu.CommandEncoderCopyBufferToBuffer(encoder, buffer_1, 0, buffer_2, 0, 16)

	command := wgpu.CommandEncoderFinish(encoder)
	wgpu.CommandEncoderRelease(encoder)
	wgpu.QueueSubmit(queue, {command})
	wgpu.CommandBufferRelease(command)

	cont :: struct {
		ready: bool,
		buff:  wgpu.Buffer,
	}
	info: cont
	info.buff = buffer_2
	buffer_cb_info: wgpu.BufferMapCallbackInfo
	buffer_cb_info.nextInChain = nil
	buffer_cb_info.mode = .AllowProcessEvents
	buffer_cb_info.userdata1 = &info
	buffer_cb_info.callback = proc "c" (
		status: wgpu.MapAsyncStatus,
		message: wgpu.StringView,
		userdata1: rawptr,
		userdata2: rawptr,
	) {
		context = state.ctx
		data := cast(^cont)userdata1
		data.ready = true

		if status != .Success {
			return
		}

		buffer_data := wgpu.BufferGetConstMappedRange(data.buff, 0, 16)
		defer wgpu.BufferUnmap(data.buff)

		fmt.print("data in the buffer: {")
		for i := 0; i < 16; i += 1 {
			if i > 0 {fmt.print(", ")}
			fmt.print(cast(int)buffer_data[i])
		}
		fmt.println("}")
	}

	wgpu.BufferMapAsync(buffer_2, {.Read}, 0, 16, buffer_cb_info)

	for info.ready != true {
		wgpu.DevicePoll(device, true)
	}
}
