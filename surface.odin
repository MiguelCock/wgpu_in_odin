package engine

import "vendor:wgpu"
import "core:fmt"

get_next_surface_data :: proc(surface: wgpu.Surface) -> (surface_texture: wgpu.SurfaceTexture, target_view: wgpu.TextureView) {
    surface_texture = wgpu.SurfaceGetCurrentTexture(surface)
    if surface_texture.status != .SuccessOptimal {
        return
    }

    view_descriptor : wgpu.TextureViewDescriptor
    view_descriptor.nextInChain = nil
    view_descriptor.label = "Surface texture view"
    view_descriptor.format = wgpu.TextureGetFormat(surface_texture.texture)
    view_descriptor.dimension = ._2D
    view_descriptor.baseMipLevel = 0
    view_descriptor.mipLevelCount = 1
    view_descriptor.baseArrayLayer = 0
    view_descriptor.arrayLayerCount = 1
    view_descriptor.aspect = .All

    target_view = wgpu.TextureCreateView(surface_texture.texture, &view_descriptor)

    return
}