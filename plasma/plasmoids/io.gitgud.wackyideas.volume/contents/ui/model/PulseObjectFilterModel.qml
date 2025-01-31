import org.kde.kitemmodels as KItemModels

import org.kde.plasma.private.volume

KItemModels.KSortFilterProxyModel {
    id: filterModel
    property /*[{ role: string, value: var }]*/ var filters: []
    property bool filterOutInactiveDevices: false
    property bool filterVirtualDevices: false

    property string defaultSinkName: ""

    onFiltersChanged: invalidate()
    onFilterOutInactiveDevicesChanged: invalidate()
    onFilterVirtualDevicesChanged: invalidate()

    filterRowCallback: function(source_row, source_parent) {
        const idx = sourceModel.index(source_row, 0, source_parent);

        // Don't ever show the dummy output, that's silly
        const dummyOutputName = "auto_null"
        if (sourceModel.data(idx, sourceModel.KItemModels.KRoleNames.role("Name")) === dummyOutputName) {
            return false;
        }

        // Optionally run the role-based filters
        for (const { role, value } of filters) {
            if (sourceModel.data(idx, sourceModel.KItemModels.KRoleNames.role(role)) !== value) {
                return false;
            }
        }

        // Optionally exclude inactive devices
        if (filterOutInactiveDevices) {
            const ports = sourceModel.data(idx, sourceModel.KItemModels.KRoleNames.role("PulseObject")).ports;
            if (ports.length === 1 && ports[0].availability === Port.Unavailable) {
                return false;
            }
        }

        if (filterVirtualDevices && sourceModel.data(idx, sourceModel.KItemModels.KRoleNames.role("PulseObject")).virtualDevice) {
            return false;
        }

        if (sourceModel.data(idx, sourceModel.KItemModels.KRoleNames.role("PulseObject")).default) {
            filterModel.defaultSinkName = sourceModel.data(idx, sourceModel.KItemModels.KRoleNames.role("Description"));
            return true;
        } else return false;
    }
}
