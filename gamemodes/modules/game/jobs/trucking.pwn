#include <YSI\y_hooks>

hook OnGameModeInit() {
	#if defined ADD_VEHICLES

	AddVehicle(530, VEHICLE_OWNER_TYPE_JOB, 38.6391, -328.9857, 1.6670, 0.0000, .owner = JOB_TRUCK);
	AddVehicle(578, VEHICLE_OWNER_TYPE_JOB, 113.2432, -254.1346, 2.5342, 90.0000, .owner = JOB_TRUCK);
	AddVehicle(584, VEHICLE_OWNER_TYPE_JOB, 99.5155, -229.6313, 2.9245, 180.0000, .owner = JOB_TRUCK);
	AddVehicle(403, VEHICLE_OWNER_TYPE_JOB, 122.8754, -269.5614, 2.1856, 90.0000, .owner = JOB_TRUCK);
	AddVehicle(414, VEHICLE_OWNER_TYPE_JOB, 126.1429, -308.2740, 1.5928, 0.0000, .owner = JOB_TRUCK);
	AddVehicle(443, VEHICLE_OWNER_TYPE_JOB, 136.1189, -333.2281, 2.2371, 0.0000, .owner = JOB_TRUCK);
	AddVehicle(450, VEHICLE_OWNER_TYPE_JOB, 98.3184, -270.4759, 2.5675, 0.0000, .owner = JOB_TRUCK);
	AddVehicle(455, VEHICLE_OWNER_TYPE_JOB, 37.9045, -235.6879, 3.5381, 270.0000, .owner = JOB_TRUCK);
	AddVehicle(478, VEHICLE_OWNER_TYPE_JOB, 126.2340, -259.0468, 1.5065, 90.0000, .owner = JOB_TRUCK);
	AddVehicle(515, VEHICLE_OWNER_TYPE_JOB, 125.8360, -278.5499, 2.6677, 90.0000, .owner = JOB_TRUCK);
	AddVehicle(514, VEHICLE_OWNER_TYPE_JOB, 123.7652, -288.5916, 2.6677, 90.0000, .owner = JOB_TRUCK);
	AddVehicle(456, VEHICLE_OWNER_TYPE_JOB, 78.4550, -336.8253, 1.7765, 0.0000, .owner = JOB_TRUCK);
	AddVehicle(478, VEHICLE_OWNER_TYPE_JOB, 126.2518, -255.8712, 1.5065, 89.9400, .owner = JOB_TRUCK);

	#endif
}