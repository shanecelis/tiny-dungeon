use nano9::{
    level::{tiled::TiledLookup},
    raycast::{Cover, Place},
};
use bevy::{
    math::bounding::Aabb2d,
    prelude::*,
};
use bevy_ecs_tiled::{
    map::components::TiledMapStorage,
    prelude::{TiledMap, TiledMapCreated},
};
use tiled::{LayerType, PropertyValue};

pub(crate) fn add_covers(
    mut tiled_map_created: EventReader<TiledMapCreated>,
    query: Query<&TiledMapStorage>,
    tiled_maps: Res<Assets<TiledMap>>,
    mut commands: Commands,
) {
    for event in tiled_map_created.read() {
        let Some(tiled_map) = tiled_maps.get(event.asset_id) else {
            continue;
        };
        let Ok(storage) = query.get(event.entity) else {
            continue;
        };
        let tile_size = Vec2::new(
            tiled_map.map.tile_width as f32,
            tiled_map.map.tile_height as f32,
        );
        for (layer_index, layer) in tiled_map.map.layers().enumerate() {
            if let LayerType::Objects(object_layer) = layer.layer_type() {
                for (index, object) in object_layer.objects().enumerate() {
                    let idx = object.id();
                    // let idx = index as u32;
                    // let x = object.x;
                    // let y = object.y;
                    let x = 0.0;
                    let y = 0.0;
                    let aabb = match object.shape {
                        tiled::ObjectShape::Rect { width, height } => {
                            if object.get_tile().is_some() {
                                Aabb2d {
                                    min: Vec2::new(x, y),
                                    max: Vec2::new(x + tile_size.x, y + tile_size.y),
                                }
                            } else {
                                Aabb2d {
                                    min: Vec2::new(x, y - height),
                                    max: Vec2::new(x + width, y),
                                }
                            }
                        }
                        // tiled::ObjectShape::Point(x, y) => {
                        //     info!("point object {}", object.name);
                        // },
                        ref x => {
                            todo!("{:?}", x)
                        }
                    };
                    if let Some(id) = storage.objects.get(&idx) {
                        if let Some(place) = object.properties.get("place") {
                            match place {
                                PropertyValue::StringValue(name) => {
                                    commands.entity(*id).insert(Place(name.to_owned()));
                                }
                                x => {
                                    warn!("Expected string value for place name not {x:?}");
                                }
                            }
                        }
                        // TODO: Make the 'flags' name configurable.
                        let flags = object
                            .properties
                            .get("flags")
                            .and_then(|v| match v {
                                PropertyValue::IntValue(v) => Some(*v as u32),
                                _ => None,
                            })
                            .unwrap_or(0);
                        commands.entity(*id).insert((
                            Cover { aabb, flags },
                            TiledLookup::Object {
                                layer: layer_index as u32,
                                idx: index as u32,
                                handle: Handle::Weak(event.asset_id),
                            },
                        ));
                    } else {
                        warn!("No entity for object {} id {}", object.name, object.id());
                    }
                }
            }
        }
    }
}
