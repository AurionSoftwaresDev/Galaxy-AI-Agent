from collections.abc import Callable

from source.gui.map.mapContextShared import map_window_instance

MAP_HANDLERS_FUNCTIONS : dict[str, Callable] = {

    "add_arrow_marks_on_coordinate": map_window_instance.add_coordinate_marker,
    "clear_all_markers": map_window_instance.clear_markers,

    "fly_to_your_location": map_window_instance.fly_to_location,
    "calculate_coordinate_distance": map_window_instance.calculate_coordinate_distance,

    "change_map_mode": map_window_instance.change_mode,
    "change_map_theme": map_window_instance.change_theme,
    "change_camera_dimension": map_window_instance.set_camera
}

__map_action_keys__ : set[str] = {
    key 
    for key, __uselessFunctionForThisItem__ in MAP_HANDLERS_FUNCTIONS.items()
}